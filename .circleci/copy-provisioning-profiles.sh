#!/bin/bash

set -eux

DIR=$(cd $(dirname $0)/.. && pwd)
DEST="${HOME}/Library/MobileDevice/Provisioning Profiles/"

mkdir -p /tmp/certs
echo $MAC_BETA_P12 | base64 -D > /tmp/certs/mac-beta.p12

mkdir -p "${DEST}"
cp ${DIR}/fastlane/mac-catalyst-provisioning-profiles/*.provisionprofile "$DEST"
