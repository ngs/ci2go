#!/bin/sh

set -eu
PROFILES="development adhoc appstore"
for I in $PROFILES; do
  fastlane match $I
done
