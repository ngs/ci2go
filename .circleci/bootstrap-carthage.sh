#!/bin/sh

set -eu

if ! cmp -s Cartfile.resolved Carthage/Cartfile.resolved; then
  carthage bootstrap --no-build
  # Patch pbxproj https://stackoverflow.com/a/52315766
  find Carthage/Checkouts \( -name '*.pbxproj' -o -name '*.xcconfig' \) -print0 | xargs -0 sed -i "" "s/WATCHOS_DEPLOYMENT_TARGET = 2.0/WATCHOS_DEPLOYMENT_TARGET = 5.0/g"
  carthage build --platform iOS,watchOS
  cp Cartfile.resolved Carthage/Cartfile.resolved
fi
