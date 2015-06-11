#!/bin/sh
set -eu

XCODE_SCHEME=$APPNAME

bundle exec ipa build \
  --workspace "$XCODE_WORKSPACE" \
  --scheme "$APPNAME" \
  --configuration Release \
  --destination Distribution/Release \
  --embed MobileProvisionings/${APPNAME}Distribution.mobileprovision \
  --identity "$DEVELOPER_NAME"

