#!/bin/bash

. /usr/local/reductor/etc/const
. "$CONFIG"

trap __exit EXIT
[ "$RED_AUTOUPDATE_ENABLED" != '1' ] && exit 0

prepare() {
	log "Запущено обновление списков РосКомНадзора" >> $LOGFILE
	echo "Пожалуйста, не прерывайте работу скрипта (ctrl+c, или закрытие окна), он выполняется достаточно долго (1-5 минут)"
	SSL_DIR=${SSLDIR}/php/
	LOG=${MAINDIR}/log
}

check_private_key() {
	if [ ! -s "$PRIVATE_KEY" ]; then
		log "Необходимо добавить экспортированный сертификат в каталог $USERDIR/" >&2
		exit 1
	fi
}

check_activate() {
	rm -f $TMPDIR/reductor_report.*
	[ "$(get_reductor_state)" != 'Активирован' ] && $BINDIR/renew_actcode.sh
	if [ "$(get_reductor_state)" != 'Активирован' ]; then
		report=$TMPDIR/reductor_report.$$
		log "Не удалось активироваться!" >> $LOGFILE
		log "Не удалось активироваться!" >&2
		log "Не могу запустить обновление списка на неактивированной копии Carbon Reductor" >&2
		cat $PROCLIST > $report
		send_alarm "$report"
		exit 2
	fi
}

chroot_work() {
	if ! $BINDIR/reductor_worker.sh; then
		log "Не удалось выполнить reductor_chroot_worker, $GOTO_SUPPORT" >&2
		log "Не удалось выполнить reductor_chroot_worker, $GOTO_SUPPORT" >> $LOGFILE
		exit 2
	fi
}

main() {
	prepare
	if [ "${SKIP_SIGN_REQUEST:-0}" != '1' ]; then
		check_private_key
	fi
	check_activate
	chroot_work
	$BINDIR/main.sh
	log "Завершено обновление списков РосКомНадзора" >> $LOGFILE
}

main
