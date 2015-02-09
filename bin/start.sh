#!/bin/bash

. /usr/local/reductor/etc/const
. /etc/init.d/functions
. $CONFIG

set -eu

trap __exit EXIT

check_reg_values() {
	[ "$RED_AUTOUPDATE_USERNAME" != 'Мегапровайдер' ]
	[ "$RED_AUTOUPDATE_EMAIL" != 'master@example.com' ]
	if [ "$RED_AUTOUPDATE_ENABLED" = '1' ]; then
		[ "$RED_AUTOUPDATE_INN" != '1234567890' ]
		[ "$RED_AUTOUPDATE_OGRN" != '1234567890123' ]
	fi
}

prepare() {
	mkdir -p $TMPDIR
	if [[ "$RED_AUTOUPDATE_URL" = *docs.carbonsoft.ru* ]]; then
		RED_AUTOUPDATE_URL='http://docs.carbonsoft.ru:1488/cache/'
		update_variable RED_AUTOUPDATE_URL 'http://docs.carbonsoft.ru:1488/cache/'
	fi
}

reg_process() {
	$BINDIR/reg_main.sh
}

main() {
	[ "$RED_AUTOUPDATE_ENABLED" != "1" ] && exit 255
	echo "# Запускается Carbon Reductor:"
	/etc/init.d/firewall restart &>/dev/null
	prepare
	check_reg_values
	reg_process
}

${1:-main}
