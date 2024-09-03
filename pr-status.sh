#!/usr/bin/bash

STATUSFILE=~/.pr-status
CONFFILE=~/.config/github.conf

TOKEN=$(cat $CONFFILE)|| { echo "Cannot read $CONFFILE"; exit 1;  }
Q="is:pr+state:open+author:@me+status:failure"

while true
do
    CURL_RESPONSE=$(curl --silent --show-error --fail -L \
        -H "Accept: application/vnd.github+json" \
        -H "Authorization: Bearer $TOKEN" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        "https://api.github.com/search/issues?q=$Q" 2>&1)

    CURL_CMD_STATUS=$?
    if [ $CURL_CMD_STATUS -ne 0 ]; then
        systemd-notify STATUS="Curl failed with status $CURL_CMD_STATUS"
        systemd-notify STATUS="Check your github token. You can update this by running the install.sh script"
        exit 1;
    fi

    TOTAL_FAILS=$(echo $CURL_RESPONSE | jq '.total_count')

    if [ $TOTAL_FAILS -ne 0 ]; then
        notify-send "PR Status" "You have $TOTAL_FAILS failing PR(s)"
        echo "FAIL" > $STATUSFILE
        sleep 300
    else
        echo "PASS" > $STATUSFILE
        sleep 30
    fi
done

