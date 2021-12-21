#!/bin/bash
#:***********************************************
#:Program: pressure_test_all
#:
#:Version: 1.0
#:***********************************************
source /etc/profile
cpu_pressure () {
    pkill -KILL pressure
    pkill -KILL pressure
    pkill -KILL pressure
    pressure_process=$(ps -ef|grep -v grep|grep pressure|grep -v pressure_test_all.sh|wc -l)
        if [ $pressure_process -eq 0 ];then
            nohup /tmp/pressure -c {{ cpu_pressure_limit }} &
        fi
}

cpumonpre () {
    cpumonpre_count=$(ps -ef|grep -v grep|grep cpumonpre|wc -l)
    if [ $cpumonpre_count -ne 4 ] ;then
        pkill -KILL cpumonpre
        pkill -KILL cpumonpre
        pkill -KILL cpumonpre
        sleep 3
        cd /etc/scripts/cpumonpre/ ; nohup ./cpumonpre 95 &
    fi
}

case $1 in
    cpu_pressure)
        cpu_pressure
    ;;
    cpumonpre)
        cpumonpre
    ;;
esac
