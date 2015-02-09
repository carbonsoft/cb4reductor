#!/bin/bash

. /usr/local/reductor/etc/const
. $CONFIG

set -eu

trap __exit EXIT

debug=0

debug() {
	[ "$debug" = '1' ] && log $@ || true
}

prepare() {
	# log prepare	
	mkdir -p $TMPDIR
	for file in ip.load http.load ip.noload http.noload http_full.noload https.resolv system.iplist system.https; do
		> $LISTDIR/$file
	done
}

remove_www() {
	sed -r -e '/http:\/\/([^\/]*[.]){3,}[^\/]*/ ! s|www[.]||'
}

remove_sharp() {
	sed -r -e '/\?.*#/ ! s/#[^\?]*(\?|$)/\1/g'
}

remove_sharp_old() {
	sed -e 's|#.*$||g'
}

normalize() {
	# remove urls of blocked domains
	grep -v ^https $1 > $1.nohttps
	mv $1.nohttps $1
	egrep ^http://[^/]+/?$ $1 > $1.domains || true
	fgrep -v -F -f $1.domains $1 > $1.without_domains || true
	sort -u $1.domains $1.without_domains | remove_www | sort -u > $1.sorted_1
	grep '#' $1.sorted_1 > $1.with_sharp || true
	grep -v '#' $1.sorted_1 > $1.without_sharp || true
	remove_sharp < $1.with_sharp > $1.fixed_sharp
	remove_sharp_old < $1.with_sharp > $1.fixed_sharp_old
	sort -u $1.{with_sharp,without_sharp,fixed_sharp,fixed_sharp_old} | $BINDIR/lower_host > $1
	egrep ".{300,}" $1 > $1.longurl || true
	egrep -v ".{300,}" $1 > $1.nolongurl || true
	$BINDIR/reduce_length < $1.longurl > $1.reduce
	LANG= sort -u $1.nolongurl $1.reduce > $1
}

whitelisting() {
	for file in "$1" "$2"; do
		LANG= sort -u "$file" > "$file.sort"
		mv -f "$file.sort" "$file"
	done
	LANG= join -a 1 -v 1 -j 1 "$2" "$1" > "$2.clean"
	mv -f "$2.clean" "$2"
}

whitelisting_fulldomain() {
	local whitelist="$1"
	local list="$2"
	local domain=''
	local noload=$whitelist.entries
	> $noload
	while read url; do
		domain="$(echo "$url" | cut -d '/' -f3)"
		grep -F "http://$domain" "$list" >> "$noload"
		grep -F -v "http://$domain" "$list" > "$list.tmp"
		mv -f "$list.tmp" "$list"
	done < $whitelist
}

categorize() {
	find $LISTDIR/ -type f -name "$1" -exec grep -v '^$' {} \; >> "$LISTDIR/$2"
}

# извлекаем из dump.xml всё что нужно
process_dump() {
	local dump="${1:-$RWDIR/dump.xml}"
	[ ! -f "$dump" ] && return 0
	[ ! -s "$dump" ] && log "WARNING: empty dump.xml" && return 0
	$BINDIR/dump_parser "$dump" > $TMPDIR/dump.parsed
	while read cmd line; do
		[ "$cmd" = 'add_url' ] && echo "$line"  >> $LISTDIR/http.load
		[ "$cmd" = 'add_ip' ] && echo "$line" >> $LISTDIR/ip.load
		[ "$cmd" = 'need_resolv' ] && echo "$line" >> $LISTDIR/https.resolv
	done < $TMPDIR/dump.parsed
	return 0
}

process_minjust() {
	$BINDIR/update_minjust.sh || true
}

load_ip() {
	if [ "${RED_HTTPS_BY_IP:-0}" = '1' ]; then
		iptables -F https_reductor
		while read ip; do
			iptables -t filter -I https_reductor -d $ip -j REJECT
		done < $LISTDIR/ip.load
	fi
}

write2proc() {
	# echo "$@" >&2
	echo "$@" > $PROCLIST # 2>/dev/null
}

load_url_and_signatures_to_proc() {
	debug load_url_and_signatures_to_proc
	local failed=0
	echo >> $LOGFILE
	log "INFO: начинаем загрузку URL в ядро" >> $LOGFILE
	write2proc clear
	while read url; do
		if ! write2proc "$url"; then
			log "ERROR: не удалось добавить $url"
			((failed++)) || true
		fi
	done < "$1"
	log "Загрузка URL в ядро закончена" >> $LOGFILE
	[ "$failed" -gt '0' ] && log "ERROR: $failed URL не было добавлено" | tee -a $LOGFILE
	echo >> $LOGFILE
	return 0

}

load_signatures_and_cache() {
	debug load_signatures_and_cache
	LANG= join -1 1 -2 2 $LISTDIR/http.load $CACHEDIR/signatures.cache | awk '{print $2" "$1}' > $TMPDIR/signatures_and_urls.tmp
	while read line; do
		echo $line
		[[ "$line" = */ ]] && echo "${line%/}" || echo "${line}/"
	done < $TMPDIR/signatures_and_urls.tmp > $TMPDIR/signatures_and_urls
	load_url_and_signatures_to_proc $TMPDIR/signatures_and_urls
}

main() {
        [ "$RED_AUTOUPDATE_ENABLED" != "1" ] && exit 255
	echo "- Обработка списков"
	prepare
	process_dump $@ &
	process_minjust &
	wait

	debug 'resolv'
	#todo move to function
	categorize '*.httpslist' system.https
	cut -d '/' -f3 $LISTDIR/system.https | sort -u > $TMPDIR/system.https.domains
	mv -f $TMPDIR/system.https.domains $LISTDIR/system.https
	sort -u $LISTDIR/system.https $LISTDIR/https.resolv > $TMPDIR/https.resolv
	cat $TMPDIR/https.resolv > $LISTDIR/https.resolv
	$BINDIR/nslookuper.sh > $LISTDIR/system.iplist

	# добавляем из минюста и собственных списков
	debug categorize
	categorize '*.iplist' ip.load &
	categorize '*.list' http.load &
	categorize '*.whiteiplist' ip.noload &
	categorize '*.whitelist' http.noload &
	categorize '*.fullwhitelist' http_full.noload &
	wait

	debug normalize
	# убираем www и uppercase host
	normalize $LISTDIR/http.load &
	normalize $LISTDIR/http.noload &
	normalize $LISTDIR/http_full.noload &
	wait

	debug whitelisting
	# при необходимости проходимся по белым спискам и вырезаем из полного списка
	whitelisting $LISTDIR/ip.noload $LISTDIR/ip.load &
	whitelisting $LISTDIR/http.noload $LISTDIR/http.load &
	whitelisting_fulldomain $LISTDIR/http_full.noload $LISTDIR/http.load &
	wait

	debug escape
	# эскейпим всё из полного списка.
	cp -f $LISTDIR/http.load $TMPDIR/http.load
	php $BINDIR/escape_url.php | LANG= sort -u > $LISTDIR/http.load

	debug load_ip
	# добавляем всё из ip.load в ipset
	load_ip

	debug renew_actcode
	# развлекаемся с сигнатурами
	$BINDIR/renew_actcode.sh

	debug signatures
	$BINDIR/update_signatures.sh

	# добавляем всё из кэша сигнатур в reductor
	load_signatures_and_cache
	debug finished
}

main $@
