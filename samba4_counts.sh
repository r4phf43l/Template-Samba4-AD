#!/bin/bash
OUT_DIR=/tmp/samba4dir
OUT_STATUS=$OUT_DIR/count.json

if [ "$1" == "getCount" ]; then
    cat $OUT_STATUS
fi

if [ "$1" == "getAllWS" ]; then
    echo $(jq -r '.TOTAL_WS' $OUT_STATUS)
fi

if [ "$1" == "getAllUsers" ]; then
    echo $(jq -r '.TOTAL_USERS' $OUT_STATUS)
fi

if [ "$1" == "getActiveWS" ]; then
    echo $(jq -r '.ACTIVE_WS' $OUT_STATUS)
fi

if [ "$1" == "getActiveUsers" ]; then
    echo $(jq -r '.ACTIVE_USERS' $OUT_STATUS)
fi

if [ "$1" == "doCount" ]; then
    lista=$(echo `pdbedit -L -v | grep "Account Flags:"`)
    delimiter="]"
    string=$lista$delimiter
    all_users=0
    all_ws=0
    active_users=0
    active_ws=0
    while [[ $string ]]; do
        block=( "${string%%"$delimiter"*}" )
        string=${string#*"$delimiter"}
        ret=$(echo $block | grep "Account Flags" | cut -f2 --delimiter='[' | cut -f1 --delimiter=' ')
        ismachine_account=`echo $ret | grep W | wc -l`
        isdeleted_account=`echo $ret | grep D | wc -l`
        if [ $ismachine_account -eq 0 -a $isdeleted_account -eq 0 ]; then
            active_users=$(($active_users+1))
        fi
        if [ $ismachine_account -eq 1 -a $isdeleted_account -eq 0 ]; then
            active_ws=$(($active_ws+1))
        fi
        if [ $ismachine_account -eq 1 ]; then
            all_ws=$(($all_ws+1))
        fi
        if [ $ismachine_account -eq 0 ]; then
            all_users=$(($all_users+1))
        fi
    done
    echo "{\"ACTIVE_USERS\":$active_users,\"TOTAL_USERS\":$all_users,\"ACTIVE_WS\":$active_ws,\"TOTAL_WS\":$all_ws}" > $OUT_STATUS
fi
exit
