#!/bin/bash

./restart.sh
dmesg -c &>/dev/null
echo 1 > /proc/net/ipt_reductor/debug_ctl 
echo 1 > /proc/net/ipt_reductor/trace_ctl 
echo print > /proc/net/ipt_reductor/block_list
dmesg
