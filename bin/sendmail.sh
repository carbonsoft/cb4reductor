#!/bin/bash

. /usr/local/reductor/etc/const
. $CONFIG

export LANG=ru_RU.KOI8-R

create_message() {
	case "$1" in
	support2admin )
		echo "From: feedback.reductor@carbonsoft.ru"
		echo "To: $RED_AUTOUPDATE_EMAIL"
		echo "Content-Type: text/plain; charset = \"KOI8-R\""
		echo "Subject: $2"
		;;
	admin2support )
		echo "From: $RED_AUTOUPDATE_EMAIL"
		echo "To: feedback.reductor@carbonsoft.ru"
		echo "Content-Type: text/plain; charset = \"KOI8-R\""
		echo "Subject: $2"
		;;
	* )
		exit 1;
		;;
	esac
	shift 2
	echo "$@"
	echo '----'
	echo "Message from $(ip r g 8.8.8.8 | egrep -o '([0-9]{1,3}\.){1,3}[0-9]{1,3} $') server on $(</etc/issue) $(get_version)"
}

sendmail() {
	/usr/bin/msmtp --host=smtp.carbonsoft.ru --port=25251 --connect-timeout=10 $@
}

main() {
	feedback="feedback.reductor@carbonsoft.ru"
	create_message admin2support "$1" "$2" | sendmail -f "$RED_AUTOUPDATE_EMAIL" -t $feedback
	create_message support2admin "$1" "$2" | sendmail -f $feedback -t "$RED_AUTOUPDATE_EMAIL"
}

main "$1" "${2:-$1}"
