#!/bin/bash

. /usr/local/reductor/etc/const
. $CONFIG

$OPENSSL smime -sign -binary -signer ${USERDIR}/provider.pem  -inkey ${USERDIR}/provider.pem -outform PEM -in ${RWDIR}/request.xml -out ${RWDIR}/request.xml.sign
