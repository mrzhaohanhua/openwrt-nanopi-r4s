#!/bin/sh
#PPPoE守护进程
pppoe_name="pppoe0"
ping_dest="223.5.5.5"
ping_count=4
fail_count=0
#开启循环
while true
do
    if (ping -q -c $ping_count $ping_dest &> /dev/null)
    then
        fail_count=0
    else
        fail_count=$(($fail_count + 1))
    fi
    if [ $fail_count -gt 2 ]
    then
        echo "Internet down, restart ${pppoe_name}"
        fail_count=0
        ifdown $pppoe_name
        sleep 2
        ifup $pppoe_name
        sleep 20
    fi
    sleep 2
done