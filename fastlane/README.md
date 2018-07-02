fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
## iOS
### ios set_build_number
```
fastlane ios set_build_number
```
Set Build Number to CIRCLE_BUILD_NUM
### ios tests
```
fastlane ios tests
```
Run tests
### ios beta
```
fastlane ios beta
```
Publish app to Fabric Beta
### ios release
```
fastlane ios release
```
Publish app to App Store
### ios screenshots
```
fastlane ios screenshots
```
Take screenshots
### ios increment_minor_version
```
fastlane ios increment_minor_version
```
Increment minor version

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
