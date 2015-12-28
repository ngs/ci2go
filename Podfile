# vim: set ft=ruby

use_frameworks!
inhibit_all_warnings!

xcodeproj 'CI2Go'

def shared_pods
  pod 'Alamofire', '~> 3.1'
  pod 'AlamofireObjectMapper', '~> 2.1'
  pod 'ObjectMapper', '~> 1.0'
  pod 'RealmSwift', '~> 0.97'
  pod 'RxBlocking', '~> 2.0.0-beta'
  pod 'RxCocoa', '~> 2.0.0-beta'
  pod 'RxSwift', '~> 2.0.0-beta'
  pod 'ANSIKit', :git => 'git@github.com:ngs/ANSIKit.git', :branch => 'cocoapods'
end

target 'CI2Go' do
  platform :ios, '8.0'
  pod 'PusherSwift', '~> 0.1'
  pod 'MBProgressHUD', '~> 0.8'
  pod "GoogleAnalytics"
  shared_pods
end

target 'CI2Go WatchKit App Extension' do
  platform :watchos, '2.0'
  shared_pods
end

target 'CI2GoTests' do
  platform :ios, '8.0'
  pod 'Quick', '~> 0.8'
  pod 'Nimble', '~> 3.0'
  pod 'OHHTTPStubs', '~> 4.7'
end

