#!/bin/sh
set -eu
DIR=tmp/certs
KEYCHAIN=$HOME/Library/Keychains/ios-build.keychain
KEYCHAIN_PASSWORD=`openssl rand -base64 48`
rm -rf $DIR
mkdir -p $DIR
echo $APPLE_AUTHORITY_BASE64 | base64 -D > $DIR/apple.cer
echo $DISTRIBUTION_KEY_BASE64 | base64 -D > $DIR/dist.p12
echo $DISTRIBUTION_CERTIFICATE_BASE64 | base64 -D > $DIR/dist.cer

security create-keychain -p "$KEYCHAIN_PASSWORD" ios-build.keychain

security import $DIR/apple.cer -k $KEYCHAIN -T /usr/bin/codesign
security import $DIR/dist.cer  -k $KEYCHAIN -T /usr/bin/codesign
security import $DIR/dist.p12  -k $KEYCHAIN -T /usr/bin/codesign -P "$KEY_PASSWORD"

security list-keychain -s $KEYCHAIN
security unlock-keychain -p "$KEYCHAIN_PASSWORD" $KEYCHAIN
echo "Removing ${DIR}"
rm -rf $DIR

echo "Downloading profiles"
bundle exec ios profiles:download:all --type distribution -u "$ITUNES_CONNECT_ACCOUNT" -p "$ITUNES_CONNECT_PASSWORD" >/dev/null 2>&1
echo "Done"
mkdir MobileProvisionings
echo "Moving mobileprovision"
mv *.mobileprovision MobileProvisionings
/bin/sh ./Scripts/install-mobileprovisioning.sh

