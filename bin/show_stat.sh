#!/bin/bash

. /usr/local/reductor/etc/const
. $CONFIG

file=/tmp/${0##*/}.$$

gen_stat() {
	echo "# Текущее время: "
	date
	echo
	echo "# Статистика модуля Carbon Reductor:"
	cat $PROCLIST
	echo
	echo "# Информация о списках:"
	ls -la $LISTDIR/*.list $LISTDIR/*.iplist $LISTDIR/*.*white*list $RWDIR/dump.xml $RWDIR/register.zip | sed -e 's/.*root//g'
	echo
	echo "# Информация о регистрации"
	fgrep RED_REG $CONFIG | egrep -v "(declare|widget)"
}

main() {
	gen_stat > $file
	show_file $file
	rm -f $file
}

${1:-main}
