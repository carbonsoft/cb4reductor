#!/bin/bash

mount -o rw,remount /mnt/ro_disc
chattr -i /usr/local/reductor/bin/reductor_worker.sh
wget "https://raw.githubusercontent.com/carbonsoft/cb4reductor/master/bin/reductor_worker.sh" -O /usr/local/reductor/bin/reductor_worker.sh
