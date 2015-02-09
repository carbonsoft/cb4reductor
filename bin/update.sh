#!/bin/bash

. /usr/local/reductor/etc/const
. "$CONFIG"

trap __exit EXIT
[ "$RED_AUTOUPDATE_ENABLED" != '1' ] && exit 0

prepare() {
	log "�������� ���������� ������� �������������" >> $LOGFILE
	echo "����������, �� ���������� ������ ������� (ctrl+c, ��� �������� ����), �� ����������� ���������� ����� (1-5 �����)"
	SSL_DIR=${SSLDIR}/php/
	LOG=${MAINDIR}/log
}

check_private_key() {
	if [ ! -s "$PRIVATE_KEY" ]; then
		log "���������� �������� ���������������� ���������� � ������� $USERDIR/" >&2
		exit 1
	fi
}

check_activate() {
	rm -f $TMPDIR/reductor_report.*
	[ "$(get_reductor_state)" != '�����������' ] && $BINDIR/renew_actcode.sh
	if [ "$(get_reductor_state)" != '�����������' ]; then
		report=$TMPDIR/reductor_report.$$
		log "�� ������� ��������������!" >> $LOGFILE
		log "�� ������� ��������������!" >&2
		log "�� ���� ��������� ���������� ������ �� ���������������� ����� Carbon Reductor" >&2
		cat $PROCLIST > $report
		send_alarm "$report"
		exit 2
	fi
}

chroot_work() {
	if ! $BINDIR/reductor_worker.sh; then
		log "�� ������� ��������� reductor_chroot_worker, $GOTO_SUPPORT" >&2
		log "�� ������� ��������� reductor_chroot_worker, $GOTO_SUPPORT" >> $LOGFILE
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
	log "��������� ���������� ������� �������������" >> $LOGFILE
}

main
