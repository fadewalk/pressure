#!/bin/bash
#:***********************************************
#:Program: pressure_test_all
#:Version: 1.0
#:***********************************************
NETWORK_PRESSURE_TIME="{{ net_pressure_time }}"
NETWORK_PRESSURE_SIZE="{{ net_pressure_size }}"

iperf_server () {
    nohup iperf -s -B {{ network_pressure_ip.stdout }} -F Mbits &>/dev/null &
}

iperf_client () {
    IPERF_CLIENT_IP="{{ network_pressure_all_ip.stdout }}"
    for n in $IPERF_CLIENT_IP
    do
        LOCAL_IP_COUNT=$(hostname -I|xargs -n 1|grep "$n"|wc -l )
        NETWORK_NAME=$(ip addr|grep "{{ network_pressure_ip.stdout }}"|awk '{print $NF}')
        NETWORK_SPEED=$(ethtool $NETWORK_NAME|grep Speed|awk '{print $2}'|awk -F "M" '{print $1}')
        CLIENT_COUNT=$(echo "$IPERF_CLIENT_IP"|xargs -n 1|wc -l)

        if [ $NETWORK_SPEED -eq 1000 ];then
            SPEED=125
        elif [ $NETWORK_SPEED -eq 2000 ];then
            SPEED=250
        elif [ $NETWORK_SPEED -eq 10000 ];then
            SPEED=1250
        elif [ $NETWORK_SPEED -eq 20000 ];then
            SPEED=2500
        fi


        if [ $LOCAL_IP_COUNT -eq 0 ];then
            (( CLIENT_COUNT = $CLIENT_COUNT -1 ))
            (( SPEED = $SPEED / $CLIENT_COUNT ))
            if [ $NETWORK_PRESSURE_SIZE -eq 100 ];then
                (( SIZE = 1 * $SPEED ))
            else
                SIZE=$(echo "0.${NETWORK_PRESSURE_SIZE} * ${SPEED}"|bc)
            fi

            nohup iperf -c $n -b ${SIZE}M -t $NETWORK_PRESSURE_TIME &>/dev/null &
        else
            echo "is local ip" &>/dev/null
        fi
    done
}

case $1 in
    iperf_server)
        iperf_server
    ;;
    iperf_client)
        iperf_client
    ;;
esac
