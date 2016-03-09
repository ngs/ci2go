fastlane documentation
================
# Installation
```
sudo gem install fastlane
```
# Available Actions
## iOS
### ios increment_version_minor
```
fastlane ios increment_version_minor
```
Increment minor number
### ios increment_version_major
```
fastlane ios increment_version_major
```
Increment major number
### ios set_build_num
```
fastlane ios set_build_num
```
Set build number to CIRCLE_BUILD_NUM
### ios build
```
fastlane ios build
```
Build AdHoc version ipa
### ios import_certs
```
fastlane ios import_certs
```
Import certs
### ios test
```
fastlane ios test
```
Runs all the tests
### ios deploy_s3
```
fastlane ios deploy_s3
```
Deploy a new version to S3
### ios deploy_testflight
```
fastlane ios deploy_testflight
```
Submit a new Beta Build to Apple TestFlight

----

This README.md is auto-generated and will be re-generated every time to run [fastlane](https://fastlane.tools)
More information about fastlane can be found on [https://fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [GitHub](https://github.com/fastlane/fastlane)