#!/bin/bash

set -eux

DIR=$(cd $(dirname $0)/.. && pwd)
DEST="${HOME}/Library/MobileDevice/Provisioning Profiles/"

mkdir -p "${DEST}"
cp ${DIR}/fastlane/mac-catalyst-provisioning-profiles/*.provisionprofile "$DEST"
