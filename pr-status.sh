#!/usr/bin/bash

STATUSFILE=~/.pr-status
CONFFILE=~/.config/github.conf

TOKEN=$(cat $CONFFILE)|| { echo "Cannot read $CONFFILE"; exit 1;  }
Q_FAIL="is:pr+state:open+author:@me+status:failure"
Q_PROGRESS="is:pr+state:open+author:@me+status:pending"

github_query() {
    local QUERY="$1"
    
    CURL_RESPONSE=$(curl --silent --show-error --fail -L \
        -H "Accept: application/vnd.github+json" \
        -H "Authorization: Bearer $TOKEN" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        "https://api.github.com/search/issues?q=$QUERY" 2>&1)

    CURL_CMD_STATUS=$?
    if [ $CURL_CMD_STATUS -ne 0 ]; then
        systemd-notify STATUS="Curl failed with status $CURL_CMD_STATUS"
        systemd-notify STATUS="Check your github token. You can update this by running the install.sh script"
        exit 1;
    fi
    echo $CURL_RESPONSE
}

while true
do
    GITHUB_FAILS_RESPONSE=$(github_query "$Q_FAIL")
    TOTAL_FAILS=$(echo $GITHUB_FAILS_RESPONSE | jq '.total_count')
    if [ $TOTAL_FAILS -ne 0 ]; then
        notify-send "PR Status" "You have $TOTAL_FAILS failing PR(s)"
        echo "FAIL" > $STATUSFILE
        sleep 300
        continue
    fi

    GITHUB_PROGRESS_RESPONSE=$(github_query "$Q_PROGRESS")
    TOTAL_PROGRESS=$(echo $GITHUB_PROGRESS_RESPONSE | jq '.total_count')
    if [ $TOTAL_PROGRESS -ne 0 ]; then
        notify-send "PR Status" "You have $TOTAL_PROGRESS in progress PR(s)"
        echo "PROGRESS" > $STATUSFILE
        sleep 60
        continue
    fi

    STATUS=$(cat $STATUSFILE)
    if [ $STATUSFILE != "PASS" ]; then
        notify-send "PR Status" "All PRs are now passing 🎉"
    fi

    echo "PASS" > $STATUSFILE
    sleep 30
done

