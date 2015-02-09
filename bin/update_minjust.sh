#!/bin/bash

set -eu

. /usr/local/reductor/etc/const
. $CONFIG

if [ "${RED_MINJUST_UPDATE_ENABLED:-0}" = 1 ]; then
	echo "- Обновляем список минюста.. "
	wget -q "$RED_AUTOUPDATE_URL"/main.minjust -O $LISTDIR/minjust.list
fi
