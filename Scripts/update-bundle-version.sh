#!/bin/bash
set -eu

for f in **/Info.plist; do
  echo $f
  /usr/libexec/PlistBuddy -c "Set :CFBundleVersion ${CIRCLE_BUILD_NUM}" "$f"
done

