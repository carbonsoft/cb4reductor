#!/bin/bash

. /usr/local/reductor/etc/const
. $CONFIG

set -eu

trap __exit EXIT
debug=0

do_cmd() {
	local cmd="$1"
	case "${cmd%% *}" in
	check_regnumber )
		__log "call $BINDIR/reg_check.sh"
		$BINDIR/reg_check.sh > $TMPFILE
		;;
	get_regnumber )
		__log "call $BINDIR/reg_get.sh"
		$BINDIR/reg_get.sh > $TMPFILE
		;;
	setregnum )
		__log "set_regnum ${cmd##* }"
		set_regnum "${cmd##* }"
		;;
	run_update )
		__log "call $BINDIR/main.sh"
		$BINDIR/main.sh
		;;
	warning )
		warning $initial
		;;
	* )
		warning "no handler for $cmd"
		;;
	esac
}

set_regnum() {
	update_variable RED_REG_REGNUMBER "$1"
	update_variable RED_REG_INSTALLCODE "$(get_reductor_instcode)"
}

__log() {
	[ "$debug" = '1' ] && log $@
	log $@ >> $LOGFILE
}

auto=1
mkdir -p $TMPDIR
TMPFILE=$TMPDIR/reg_initial.sh
is_module_loaded
check_connect
$BINDIR/reg_initial.sh > $TMPFILE
read initial < $TMPFILE
do_cmd "$initial"
read postinitial < $TMPFILE
do_cmd "$postinitial"
rm -f $TMPFILE
