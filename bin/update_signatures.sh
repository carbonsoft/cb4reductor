#!/bin/bash

. /usr/local/reductor/etc/const
. $CONFIG

set -eu

prepare() {
	mkdir -p $TMPDIR $CACHEDIR
	params="$(get_reg_params)"
	URI="${RED_AUTOUPDATE_URL}/index.php?$params"
}

show_unsigned_url() {
	touch $CACHEDIR/signatures.cache
	LANG= sort -u -k2 $CACHEDIR/signatures.cache > $TMPDIR/signed_url
	LANG= sort -u -k1 $LISTDIR/http.load > $TMPDIR/url_to_load
	LANG= join -a 1 -j1 1 -j2 2 -v 1 $TMPDIR/url_to_load $TMPDIR/signed_url | awk '{print $1}'
}

append_signatures() {
	local num=1
	[ "$loop_count" = '1' ] && echo -n '- Подгрузка недостающих сигнатур' || echo -n "."
	while read f; do
		echo -n "$((num++))=$(echo $f | $BASE64 | tr '+' '_')&"
	done <<< "$(head -n 300 $TMPDIR/unsigned_url)" > $TMPDIR/curl_post_request
	curl -sS -d "$(<$TMPDIR/curl_post_request)" "$URI" > $TMPDIR/new_signatures
	LANG= sort -u -k2 $CACHEDIR/signatures.cache $TMPDIR/new_signatures > $TMPDIR/merged_signatures 2>/dev/null
	LANG= sort -u -k2 $TMPDIR/merged_signatures > $CACHEDIR/signatures.cache
	rm -f $TMPDIR/merged_signatures $TMPDIR/new_signatures
}

main() {
	prepare
	prev_count=0
	loop_count=1
	while show_unsigned_url > "$TMPDIR/unsigned_url"; do
		if [ "$(wc -l < $TMPDIR/unsigned_url)" -le '0' ]; then
			[ "$loop_count" -gt 1 ] && echo
			break
		fi
		url_count=$(wc -l < $TMPDIR/unsigned_url)
		if [ "$prev_count" = "$url_count" ]; then
			log "ERROR: loop stucked, skip get url_count=$url_count"
			cat $TMPDIR/unsigned_url
			break
		fi
		prev_count=$url_count
		append_signatures
		# in case of stucked, ideal -doesn't called, coz need get <1000 signatures
		sleep $((loop_count < 5 ? loop_count++ : 5))
	done
}

main $@
