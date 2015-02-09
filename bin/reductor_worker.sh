#!/bin/bash

. /usr/local/reductor/etc/const
. $CONFIG

if [ "${SKIP_SIGN_REQUEST:-0}" != '1' ]; then
	if ! $BINDIR/gen_request.sh; then
		log "Cant gen request.xml" | tee -a $LOGFILE
		exit 3
	fi

	if ! $BINDIR/sign_request.sh; then
		log "Cant sign request" | tee -a $LOGFILE
		exit 4
	fi
fi

rm -f $RWDIR/dump.xml* $RWDIR/register.zip

log "Run RKN lists update" >> $LOGFILE

php $BINDIR/send.php | iconv -f utf8 | tee -a $LOGFILE

if [ ! -f $RWDIR/register.zip ]; then
	log "No register zip, bad" | tee -a $LOGFILE
	exit 1
fi

cd $RWDIR
/usr/local/ics/bin/7z -y e register.zip

if [ ! -f $RWDIR/dump.xml ]; then
	log 'No dump.xml after unzip, bad' | tee -a $LOGFILE
	exit 2
fi

log "Alles ist good in update" | tee -a $LOGFILE
