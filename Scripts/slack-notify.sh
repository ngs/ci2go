#!/bin/bash
set -eu

PAYLOAD=`ruby -rjson -e "print ({ channel: ENV['SLACK_CHANNEL'], username: ENV['APPNAME'], text: ARGV[0], icon_url: ENV['ICON_URL'] }).to_json" "$1"`
echo $PAYLOAD

curl -X POST --silent --data-urlencode "payload=${PAYLOAD}" $SLACK_WEBHOOK_URL
