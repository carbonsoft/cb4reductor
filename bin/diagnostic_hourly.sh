#!/bin/bash

. /usr/local/reductor/etc/const
. $CONFIG

export LANG=ru_RU.UTF8

TMPFILE=$TMPDIR/diagnostic_hourly.sh.$$
LOGFILE=$LOGDIR/${0##*/}.log
DIAGDIR=/var/lib/reductor/diagnostic/
MD5SUM=$DIAGDIR/messages.md5sum

have_bugs() {
	[ "$(get_reductor_state)" != 'Активирован' ] && return 0
	grep '\[.*\]' $TMPFILE | grep -q 'СБОЙ'
}

is_already_send() {
	mkdir -p $DIAGDIR
	read md5 tmp <<< "$(egrep -v "(ACCEPT|DROP)" $TMPFILE | md5sum)"
	touch $MD5SUM
	[ "$(( $(date +%H) % 6))" = '0' ] && > $MD5SUM
	grep -q "$md5" "$MD5SUM"
	retval=$?
	[ "$retval" != 0 ] && echo $md5 >> "$MD5SUM"
	return $retval
}

main() {
	[ "${misc['diagnostic']}" != '1' ] && return 0
	$BINDIR/diagnostic.sh auto > $TMPFILE

	if is_already_send; then
		echo "$(log_date) Сообщение уже было отослано" >> $LOGFILE
		return 0
	fi

	if ! have_bugs; then
		echo "$(date +"%Y-%m-%d %H:%M:%S") Всё в порядке" >> $LOGFILE
		return 0
	fi

	send_alarm $TMPFILE
	tee -a $LOGFILE < $TMPFILE >> ${LOGFILE//.log/_err.log}
}

main $1
rm -f $TMPDIR/diagnostic_hourly.*
