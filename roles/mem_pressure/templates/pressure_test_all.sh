#!/bin/bash
#:***********************************************
#:Program: pressure_test_all
#:
#:Version: 1.0
#:***********************************************
mem_pressure_install () {
    cd /tmp/memtester-4.2.2/
    make && make install
    cp -f memtester /sbin/
}

mem_pressure () {
    mem_all=$(free -h|awk 'NR==2 {print $2}'|awk -F "G" '{print $1}'|xargs)
    mem=`free -g|grep Mem|awk '{print $4}'`
    mem=$(echo "${mem_all}*0.{{ mem_pressure_limit }}"|bc|awk -F '.' '{print $1}')
    pkill -9 memtester
    pkill -9 memtester
    pkill -9 memtester
    nohup memtester ${mem}G  > /tmp/memtest.log &
}

case $1 in
    mem_pressure_install)
        mem_pressure_install
    ;;
    mem_pressure)
        mem_pressure
    ;;
esac
