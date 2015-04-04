require 'rubygems/version'
require 'rake/clean'
require 'date'
require 'dotenv/tasks'
require 'command-builder'
require 'base64'

APP_NAME = "CI2GO"

namespace :env do
  desc 'Generate Environment.swift'
  task :export => :dotenv do
    prefix = "#{APP_NAME.upcase}_"
    code = ''
    ENV.each{|k, v|
      if k.start_with?(prefix)
        code += %Q{let #{k.sub prefix, ''} = "#{v}"\n}
      end
    }
    file = File.join __dir__, APP_NAME, 'Environment.swift'
    File.write file, code
  end
end

