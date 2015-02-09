#!/bin/bash

. /usr/local/reductor/etc/const
. $CONFIG

file=/tmp/${0##*/}.$$

gen_stat() {
	echo "# ������� �����: "
	date
	echo
	echo "# ���������� ������ Carbon Reductor:"
	cat $PROCLIST
	echo
	echo "# ���������� � �������:"
	ls -la $LISTDIR/*.list $LISTDIR/*.iplist $LISTDIR/*.*white*list $RWDIR/dump.xml $RWDIR/register.zip | sed -e 's/.*root//g'
	echo
	echo "# ���������� � �����������"
	fgrep RED_REG $CONFIG | egrep -v "(declare|widget)"
}

main() {
	gen_stat > $file
	show_file $file
	rm -f $file
}

${1:-main}
