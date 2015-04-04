#!/bin/bash
set -eu

v=`/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString $CIRCLE_BUILD_NUM" "${APPNAME}/Info.plist"`

for f in `ls **/Info.plist`; do
  echo $f
  /usr/libexec/PlistBuddy -c "Set :CFBundleVersion ${v}.${CIRCLE_BUILD_NUM}" "$f"
done

