#!/bin/sh
set -eu

bundle exec ipa distribute:itunesconnect \
  --file Distribution/Release/${APPNAME}.ipa \
  --account $ITUNES_CONNECT_ACCOUNT \
  --password $ITUNES_CONNECT_PASSWORD \
  --apple-id $APPLE_ID \
  --warnings \
  --errors \
  --upload
