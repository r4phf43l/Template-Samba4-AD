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

if [ "$1" == "getTodayLogin" ]; then
    echo $(jq -r '.USERS_TODAY' $OUT_STATUS)
fi

if [ "$1" == "getHourLogin" ]; then
    echo $(jq -r '.USERS_LAST_HOUR' $OUT_STATUS)
fi

if [ "$1" == "getTodayWS" ]; then
    echo $(jq -r '.WS_TODAY' $OUT_STATUS)
fi

if [ "$1" == "getHourWS" ]; then
    echo $(jq -r '.WS_LAST_HOUR' $OUT_STATUS)
fi

if [ "$1" == "doCount" ]; then
    today=$(date '+%d %b %Y')
    last_hour=$(date '+%d %b %Y %H')

    lista=$(pdbedit -L -v | grep -E "^Account Flags:|^Logon time:")
    all_users=0
    all_ws=0
    active_users=0
    active_ws=0
    today_logged_users=0
    today_logged_ws=0
    hour_logged_users=0
    hour_logged_ws=0

    # Processa as linhas de entrada e extrai as informações dos usuários
    while IFS= read -r line; do
        if [[ $line == "Account Flags:"* ]]; then
            account_flags=$(echo "$line" | awk -F: '{print $2}' | awk '{$1=$1};1')
        elif [[ $line == "Logon time:"* ]]; then
            logon_time=$(echo "$line" | awk -F: '{print $2}' | awk '{$1=$1};1')
            ismachine_account=`echo $account_flags | grep W | wc -l`
            isdeleted_account=`echo $account_flags | grep D | wc -l`
            islog_today_account=`echo $logon_time | grep "$today" | wc -l`
            islog_hour_account=`echo $logon_time | grep "$last_hour" | wc -l`
            if [ $ismachine_account -eq 0 -a $isdeleted_account -eq 0 -a $islog_today_account -eq 1 ]; then
                today_logged_users=$(($today_logged_users+1))
            fi
            if [ $ismachine_account -eq 0 -a $isdeleted_account -eq 0 -a $islog_hour_account -eq 1 ]; then
                hour_logged_users=$(($hour_logged_users+1))
            fi
            if [ $ismachine_account -eq 1 -a $isdeleted_account -eq 0 -a $islog_today_account -eq 1 ]; then
                today_logged_ws=$(($today_logged_ws+1))
            fi
            if [ $ismachine_account -eq 1 -a $isdeleted_account -eq 0 -a $islog_hour_account -eq 1 ]; then
                hour_logged_ws=$(($hour_logged_ws+1))
            fi
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
        fi
    done <<< "$lista"
    echo "{\"ACTIVE_USERS\":$active_users,\"TOTAL_USERS\":$all_users,\"ACTIVE_WS\":$active_ws,\"TOTAL_WS\":$all_ws,\"USERS_TODAY\":$today_logged_users,\"USERS_LAST_HOUR\":$hour_logged_users,\"WS_TODAY\":$today_logged_ws,\"WS_LAST_HOUR\":$hour_logged_ws,\"TIMESTAMP\":\"$last_hour\"}" > $OUT_STATUS
fi
exit
