#!/bin/bash

exec 2>&1

echo "$(date +"%Y-%m-%d %H:%M:%S") $HOSTNAME ${0##*/}[$$]: $@" started

if [ "$1" != auto ] && ! dialog --yesno "�������� Carbon Reductor? �������� ����������� ������������." 0 0; then
	exit 0
fi

wget "http://download5.carbonsoft.ru/carbon_reductor/update_reductor.sh" -O /tmp/update_reductor.sh
chmod a+x /tmp/update_reductor.sh && bash /tmp/update_reductor.sh

if [ "$1" != auto ]; then
	read -p "������� enter ��� �����������..." tmp
fi
