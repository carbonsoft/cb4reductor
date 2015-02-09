#!/bin/bash

. /usr/local/reductor/etc/const

sed -e 's/></>\n</g' "${1:-$RWDIR/dump.xml}"
