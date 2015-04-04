#!/bin/sh
set -eu

DIST_PATH="${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME}/${CIRCLE_BUILD_NUM}"

bundle exec ipa distribute:s3 \
  --file Distribution/AdHoc/${APPNAME}.ipa \
  --dsym Distribution/AdHoc/${APPNAME}.app.dSYM.zip \
  --access-key-id=$AWS_ACCESS_KEY_ID \
  --secret-access-key=$AWS_SECRET_ACCESS_KEY \
  --path=$DIST_PATH \
  --bucket=$S3_BUCKET \
  --acl=public-read \
  --region=$AWS_REGION \
  --create

bundle exec rake adhoc:upload
