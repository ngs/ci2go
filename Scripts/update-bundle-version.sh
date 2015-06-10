#!/bin/bash
set -eu

for f in `ls **/Info.plist`; do
  echo $f
  /usr/libexec/PlistBuddy -c "Set :CFBundleVersion ${CIRCLE_BUILD_NUM}" "$f"
done

