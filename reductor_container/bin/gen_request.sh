#!/bin/bash

. /config

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

date="$(date +%Y-%m-%dT%H:%M:%S.000%:z)"
operator="${autoupdate['operator']}"
inn="${autoupdate['inn']}"
ogrn="${autoupdate['ogrn']}"
email="${autoupdate['email']}"

tmpltfile=/gost-ssl/php/request.xml.tmplt
conffile=/gost-ssl/php/request.xml

genconfig

