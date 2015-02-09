#!/bin/bash

. /usr/local/reductor/etc/const
. /etc/init.d/functions
. $CONFIG

remove_rules_by_pattern() {
	local table=$1
	local chain=$2
	local pattern=$3
	iptables -t $table --line -nvL $chain | grep -i $pattern | tac > $TMPDIR/stop.sh
	while read num tmp; do
		iptables -t $table -D $chain $num
	done < $TMPDIR/stop.sh
}

remove_reductor_rules() {
	remove_rules_by_pattern filter FORWARD reductor
}

main() {
	mkdir -p $TMPDIR
	echo "# Отключается Carbon Reductor:"
	echo "- Удаляются все фильтрующие правила..."
	remove_reductor_rules
}

main
