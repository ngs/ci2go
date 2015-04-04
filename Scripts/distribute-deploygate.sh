#!/bin/sh
set -eu

bundle exec ipa distribute:deploygate \
  --file Distribution/AdHoc/${APPNAME}.ipa \
  --api_token $DEPLOYGATE_API_TOKEN \
  --distribution_key $DEPLOYGATE_DISTRIBUTION_KEY \
  --release_note $RELEASE_NOTE \
  --visibility public \
  --user_name $DEPLOYGATE_USERNAME
