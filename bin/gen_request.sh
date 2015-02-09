#!/bin/bash

. /usr/local/reductor/etc/const
. $CONFIG

export LANG=ru_RU.KOI8-R

genconfig() 
{
	while IFS= read -r line; do
		if [ "${line:0:1}" = "#"  ]; then
			echo "$line"
			continue
		fi
		while [[ "$line" = *@@@*%%%* ]]; do
			VARNAME=""
			VARNAME="${line#*@@@}"
			VARNAME="${VARNAME%%%%%*}"
			VARVALUE=""
			[ "$VARNAME" != "" ] && eval VARVALUE="\$$VARNAME"
			line="${line//@@@$VARNAME%%%/$VARVALUE}"
		done
		echo "$line"
	done < $tmpltfile | iconv -t cp1251 >$conffile
}

s="$(date +%z)"
z="$(echo ${s%??}:${s#???})"
date="$(date +%Y-%m-%dT%H:%M:%S.000)$z"

# acp cannot into +%s
# date="$(date +%Y-%m-%dT%H:%M:%S.000%:z)"
operator="${RED_AUTOUPDATE_USERNAME}"
inn="${RED_AUTOUPDATE_INN}"
ogrn="${RED_AUTOUPDATE_OGRN}"
email="${RED_AUTOUPDATE_EMAIL}"

tmpltfile=$RWDIR/request.xml.tmplt
conffile=$RWDIR/request.xml

genconfig
