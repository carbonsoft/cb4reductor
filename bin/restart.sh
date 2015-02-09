#!/bin/bash

. /etc/init.d/functions
. /usr/local/reductor/etc/const

log restart >> $LOGDIR/reductor.log
${BINDIR}/stop.sh
echo_result
${BINDIR}/start.sh
echo_result
