source 'https://rubygems.org'

gem 'fastlane'
gem 'xcov', git: 'https://github.com/ngs/xcov.git', branch: 'quote-file-path'
gem 'pry'

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
