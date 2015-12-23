# vim: set ft=ruby

use_frameworks!
inhibit_all_warnings!

def shared_pods
  pod "AFNetworking", '~> 2.6.3'
  pod "MagicalRecord", '2.3.0'
  pod "DateTools"
end

target 'CI2Go' do
  platform :ios, '8.0'
  shared_pods
  pod 'MBProgressHUD', '~> 0.8'
  pod "GoogleAnalytics"
end

target 'CI2Go WatchKit Extension' do
  platform :watchos, '2.0'
  shared_pods
end
