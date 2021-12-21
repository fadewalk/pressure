#!/bin/bash
#:***********************************************
#:Program: pressure_test_all
#:
#:Version: 1.0
#:***********************************************
HOSTNAME=$(hostname)
DISK_LIST=$(cat /tmp/diskconfig|xargs)
DATE_TIME=$(date +%F_%T)

disk_pressure_test () {
    mkdir -p /tmp/${HOSTNAME}_DISK_PRESSURE_DATA
    for n in $DISK_LIST
    do
        DISK_LIST_NAME=$(echo "$n"|awk -F "/" '{print $NF}')
        echo "-$n $DATE_TIME ---------------------------" >/tmp/${HOSTNAME}_DISK_PRESSURE_DATA/${HOSTNAME}_${DISK_LIST_NAME}_{{ disk_block_size }}_{{ disk_readwrite_type }}_{{ disk_test_time }}.txt
        nohup fio -filename=$n -direct=1 -iodepth={{ disk_iodepth }} -rw={{ disk_readwrite_type }} -ioengine=libaio -bs={{ disk_block_size }} -size=0g -numjobs={{ disk_numjobs }} -runtime={{ disk_test_time }} -group_reporting -name=mytest &>>/tmp/${HOSTNAME}_DISK_PRESSURE_DATA/${HOSTNAME}_${DISK_LIST_NAME}_{{ disk_block_size }}_{{ disk_readwrite_type }}_{{ disk_test_time }}.txt &
    done
}

disk_pressure_test_data () {
    cd /tmp/$HOSTNAME/
    echo "#$HOSTNAME $DATE_TIME ###########################################################" >${HOSTNAME}_disk_all.txt
    for n in $DISK_LIST
    do
        DISK_LIST_NAME=$(echo "$n"|awk -F "/" '{print $NF}')
        cat ${HOSTNAME}_${DISK_LIST_NAME}.txt|grep -E "(^-|READ|$DISK_LIST_NAME)" >>${HOSTNAME}_disk_all.txt
    done
    cd /tmp && tar zcf ${HOSTNAME}_{{ disk_block_size }}_{{ disk_readwrite_type }}_disk_{{ disk_test_time }}.tar.gz ${HOSTNAME}
}

case $1 in
    disk_pressure_test)
        disk_pressure_test
    ;;
    disk_pressure_test_data)
        disk_pressure_test_data
    ;;
esac
