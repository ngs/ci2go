# vim: set ft=ruby

use_frameworks!
inhibit_all_warnings!

def shared_pods
  pod 'Alamofire', '~> 3.1'
  pod 'AlamofireObjectMapper', '~> 2.1'
  pod 'Carlos', '~> 0.5'
  pod 'ObjectMapper', '~> 1.0'
  pod 'RealmSwift', '0.97.0'
  pod 'RxBlocking', '~> 2.0.0-beta'
  pod 'RxCocoa', '~> 2.0.0'
  pod 'RxSwift', '~> 2.0.0'
  pod 'DateTools', '~> 1.7'
end

def ios_pods
  shared_pods
  pod 'MBProgressHUD', '~> 0.8'
  pod 'GoogleAnalytics', '~> 3.14'
  pod 'RealmResultsController', '~> 0.3.1'
  pod 'PusherSwift', git: 'https://github.com/pusher-community/pusher-websocket-swift.git', commit: '888319d2d2aa9951c3a2b421ac20736139360f4e'
end

target 'CI2Go' do
  ios_pods
end

target 'CI2Go WatchKit App Extension' do
  platform :watchos, '2.0'
  shared_pods
end

target 'CI2GoTests' do
  ios_pods
  pod 'Quick', '~> 0.8'
  pod 'Nimble', '~> 3.0'
  pod 'OHHTTPStubs', '~> 4.7'
  pod 'OHHTTPStubs/Swift', '~> 4.7'
end

target 'CI2GoUITests' do
end
