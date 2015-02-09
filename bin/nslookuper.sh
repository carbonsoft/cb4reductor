#!/bin/bash

. /usr/local/reductor/etc/const
. $CONFIG

[ -s $LISTDIR/https.resolv ] || exit 0

lookup() {
	timeout -1 -1  nslookup -sil "$1" | grep -A 1000 ^Name | egrep -o "$ip_regex"
}

if [ "${RED_HTTPS_BY_IP:-0}" = '1' -a "${RED_HTTPS_BY_NSLOOKUP:-0}" = '1'  ]; then
	echo "- Резолвим https-ресурсы" >&2
	while read domain tmp; do
		lookup "$domain"
	done < $LISTDIR/https.resolv
fi # | sort -n | uniq
