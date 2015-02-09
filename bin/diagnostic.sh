#!/bin/bash

. /usr/local/reductor/etc/const
. /etc/init.d/functions
. $CONFIG
. $MAINDIR/etc/messages

fix_failed_test() {
	echo
	echo "Попытка исправить $cmd"
	case $cmd in
		check_bridge )
			check_bridge_error
			;;
		is_module_load )
			is_module_load_fix
			;;
		check_proc_values )
			check_proc_values_error
			;;
		check_tcpdump_http_mirror )
			check_tcpdump_http_mirror_error
			;;
		check_cert )
			check_cert_error
			;;
		check_key_in_cert )
			check_key_in_cert_error
			;;
		check_total_packets )
			check_total_packets_error
			;;
		check_block_fact )
			check_block_fact_error
			;;
		check_url_modify )
			check_url_modify_error
			;;
		check_list_actuality )
			check_list_actuality_fix
			;;
		check_activation )
			check_activation_fix
			;;
		check_disk_space )
			check_disk_space_error
			;;
		check_cert_date )
			check_cert_date_error
			;;
		* )
			echo "Для этого автоматическое исправление ещё не придумано..."
			;;
	esac
	echo
	return 0
}

run_test() {
	local quiet=0
	if [ "$1" = 'quiet' ]; then
		local quiet=1
		shift
	fi
	cmd="$1"
	shift
	descr="$@"
	echo -n "$descr"
	$cmd
	retval=$?

	[ "$quiet" = '1' ] && return $retval

	if [ "$retval" = '0' ]; then
		echo_success 
	else
		echo_failure
		if [ "${misc['diagnosticfix']}" = '1' ]; then
			fix_failed_test "$1"
		fi
	fi
	echo
	return $retval
}

is_module_load() {
	[ -f /proc/net/ipt_reductor/block_list ]
}

check_tcpdump_http_mirror() {
	timeout -10 -15 tcpdump -c 1 -nni any tcp port 80 &>/dev/null
}

check_proc_values() {
	grep -q '1' /proc/sys/net/ipv4/ip_forward || return 1
}

check_cert() {
	[ "$RED_AUTOUPDATE_ENABLED" != '1' ] && return 0
	[ -s $USERDIR/provider.pem ]
}

check_key_in_cert() {
	grep -q 'PRIVATE KEY' $USERDIR/provider.pem
}

check_list_actuality() {
	[ "$RED_AUTOUPDATE_ENABLED" != '1' ] && return 0
	last_modify_date=$(stat -c "%Y" $RWDIR/register.zip)
	current_date=$(date +%s)
	[ -z "$last_modify_date" ] && return 1
	[ -z "$current_date" ] && return 1
	[ "$((current_date - last_modify_date))" -lt "$((60*60*12))" ]
}

check_block_fact() {
        ! grep -q 'Match.*\<0\>$' $PROCLIST
}

check_total_packets() {
        ! grep -q 'Total packets checked:\s*0' $PROCLIST
}

check_url_modify() {
	[ -z "$RED_AUTOUPDATE_URL" ] && return 1
	[[ "$RED_AUTOUPDATE_URL" != *docs.carbonsoft.ru* ]] && return 0
	[ "$RED_AUTOUPDATE_URL" = 'http://docs.carbonsoft.ru:1488/cache/' ]
}

check_activation() {
	[ "$(get_reductor_state)" = 'Активирован' ]
}

check_cert_date() {
	days_before_finish=$((($(date +%s --date="$(/usr/local/reductor/bin/check_cert_date auto | grep notAfter | cut -d '=' -f2)") - $(date +%s))/86400))
	echo -n " $days_before_finish дней"
	[ "$days_before_finish" -gt '14' ]
}

check_cert_date_error() {
	echo "Нужно приобрести новый сертификат"
}

dummy() {
	return 1
}

main() {
	local retval=0
	[ "$1" = 'skip' ] && return 0
	[ "$1" != 'auto' ] && clear || set_consoletype_serial
	echo "Проверка распространённых ошибок настройки, мешающих работе Carbon Reductor:"
	echo
	run_test check_activation "Проверка состояния активации..." || ((retval++))
	run_test is_module_load "Подгрузка модуля..." || ((retval++))
	run_test check_proc_values "Проверка proc-параметров..." || ((retval++))

	if [ "$RED_AUTOUPDATE_ENABLED" = '1' ]; then
		run_test check_cert "Наличие сертификата..." || ((retval++))
		if check_cert; then
			run_test check_key_in_cert "Наличие закрытого ключа в provider.pem..." || ((retval++))
		fi
		if check_cert; then
			run_test check_cert_date "Время до конца работы ключа provider.pem" || ((retval))
		fi
	fi

	run_test check_list_actuality "Проверка актуальности списков..." || ((retval++))
	run_test check_total_packets "Наличие проверенных пакетов..." || ((retval++))
	if check_total_packets; then
		run_test check_block_fact "Наличие факта блокировки (если были попытки)..." || ((retval++))
	fi
	run_test check_tcpdump_http_mirror "Наличие трафика в tcpdump..." || ((retval++))
	run_test check_url_modify "Исправление URL сервера сигнатур..." || ((retval++))
	if [ "$1" != 'auto' ]; then
		echo
		read -p "Нажмите ENTER" tmp
	fi
	if [ "$retval" -gt '0' ]; then
		echo 'Внимание!'
		echo 'Возможна некорректная работа продукта!'
	fi
	return $retval
}

main $@
