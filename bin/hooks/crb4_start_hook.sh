#!/bin/bash

[ -f /etc/ics/ics.conf ] || return 0

main() {
        echo "Запускается Carbon Reductor:"
        reg_process             || exit 1
        load_url                || exit 2
	/etc/init.d/firewall restart &>/dev/null
}
