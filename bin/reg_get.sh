#!/bin/bash

. /usr/local/reductor/etc/const
. $CONFIG

URI="${RED_AUTOUPDATE_URL}/reg.php?regnumber=${RED_REG_REGNUMBER}&installcode=$(get_reductor_instcode)&actcode=${RED_REG_ACTCODE}&email=${RED_AUTOUPDATE_EMAIL}&company=${RED_AUTOUPDATE_USERNAME}"
log curl "$URI" >> $LOGFILE
curl "$URI" 2>>$LOGFILE | grep -v "^$" | sed 's/^#//g'
