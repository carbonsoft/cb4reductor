#!/bin/bash

. /usr/local/reductor/etc/const
. $CONFIG

set -eu

auto=1
is_module_loaded || __terminate 'Модуль Carbon Reductor не загружен!'
check_connect    || __terminate "$NO_CONNECTION"

RED_REG_INSTALLCODE="$(get_reductor_instcode)"
params="$(get_reg_params)"
URI="$RED_AUTOUPDATE_URL/renew_actcode.php?$params"
mkdir -p $TMPDIR

get_new_actcode() {
	curl "$URI" 2>>$LOGDIR/$(basename $0).log > $TMPDIR/actcode
	if grep -qv '^[0-9.-]*$' $TMPDIR/actcode; then
		echo $RED_REG_ACTCODE
	else
		cat $TMPDIR/actcode
	fi
}

write2conf() {
	RED_REG_ACTCODE="$1"
	update_variable RED_REG_ACTCODE "$RED_REG_ACTCODE"
}

write2proc() {
	echo "unlock_$1" > $PROCLIST
}

main() {
	new_actcode="$(get_new_actcode)"
	write2conf $new_actcode
	write2proc $new_actcode
}

main $@
