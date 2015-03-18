#!/bin/bash

mount -o rw,remount /mnt/ro_disc

echo "updating escape_url to avoid blocking problem with daymohk"
chattr -i /usr/local/reductor/bin/escape_url.php
wget "https://raw.githubusercontent.com/carbonsoft/cb4reductor/master/bin/escape_url.php" -O /usr/local/reductor/bin/escape_url.php
