#!/bin/bash

. /usr/local/Reductor/etc/const
. $CONFIG

terminate() {
	echo $@
	exit 1
}

old_version=$(</usr/local/Reductor/etc/version)
[ -z "$old_version" ] && old_version=100000

prepare() {
	/etc/init.d/reductor stop
}

backup() {
	mv /usr/local/Reductor /usr/local/old_Reductor.$old_version
}

update() {
	rpm -Uvh --nomd5 /tmp/reductor.rpm
}

restore() {
	cp -vp /usr/local/old_Reductor.$old_version/lists/*.list /usr/local/Reductor/lists/
	cp -vp /usr/local/old_Reductor.$old_version/userinfo/*.pem /usr/local/Reductor/userinfo/
	cp -vp /usr/local/old_Reductor.$old_version/userinfo/*.pfx /usr/local/Reductor/userinfo/
	mkdir -p /usr/local/Reductor/userinfo/backups/
	cp -vrp /usr/local/old_Reductor.$old_version/userinfo/backups/ /usr/local/Reductor/userinfo/backups/
	return 0
}

merge_config() {
        local CONFIG=/usr/local/Reductor/userinfo/config
        local OLDCFG=/usr/local/old_Reductor.$old_version/userinfo/config
        local TMPCONFIG=/tmp/out.cfg
        
        . $CONFIG

        while IFS== read -r var val; do
                [[ "$var" == \#* ]] && echo $var $val && continue
                [ "$var" = '' ] && echo && continue
                [[ "$var" = declare* ]] && echo $var $val && continue
                [[ "$var" != *widget* ]] && . $OLDCFG
                echo "$var='${!var}'"
                . $CONFIG
        done < $CONFIG > $TMPCONFIG
        cp -f $CONFIG /usr/local/Reductor/backups/config_$(date +%H.%M.%S_%m-%Y)
        cp -f $TMPCONFIG $CONFIG
        rm -f $TMPCONFIG
}

run_hooks() {
	for hook in /usr/local/Reductor/contrib/hooks/*; do
		echo Выполняется хук $hook
		$hook
	done
}

start_work() {
	/etc/init.d/reductor start
}

main() {
	prepare || terminate "prepare failed"
	backup || terminate "backup failed"
	if ! update; then
		sleep 5
		terminate "update failed" 
	fi
	restore || terminate "restore failed"
	merge_config || terminate "merge_config failed"
	run_hooks || terminate "run_hooks failed"
	start_work || terminate "start_work failed"
}

${1:-main}
