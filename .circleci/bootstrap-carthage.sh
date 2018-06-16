#!/bin/sh

set -eu

if ! cmp -s Cartfile.resolved Carthage/Cartfile.resolved; then
  carthage bootstrap && cp Cartfile.resolved Carthage/Cartfile.resolved
fi
