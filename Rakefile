require 'rubygems/version'
require 'rake/clean'
require 'date'
require 'dotenv/tasks'
require 'command-builder'
require 'base64'
require 'erb'
require 'aws-sdk'
require 'shenzhen'

APP_NAME = ENV['APPNAME']
ADHOC_DIR = 'Distribution/AdHoc'

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

def upload_path
  "#{ENV['CIRCLE_PROJECT_USERNAME']}/#{ENV['CIRCLE_PROJECT_REPONAME']}/#{ENV['CIRCLE_BUILD_NUM']}"
end

def s3_upload(src)
  s3 = AWS::S3.new
  bucket = s3.buckets[ENV['S3_BUCKET']]
  obj = nil
  File.open(src) do |fd|
    obj = bucket.objects.create "#{upload_path}/#{File.basename(src)}", fd, acl: acl
  end
  obj.public_url.to_s
end

class AdHocPage
  attr_accessor :name
  def initialize(name)
    @name = name
  end
  def render
    ERB.new(IO.read("Resources/adhoc-templates/#{name}.erb")).result(binding)
  end
  def plist_print(key)
    # %x{/usr/libexec/PlistBuddy -c "Print :#{key}" #{APP_NAME}/Info.plist}.strip
    Shenzhen::PlistBuddy.print "#{APP_NAME}/Info.plist", key
  end
  def filesize
    File.open("#{ADHOC_DIR}/#{APP_NAME}.ipa").size
  end
  def ipa_url
    "https://#{ENV['S3_BUCKET']}.s3.amazonaws.com/#{upload_path}/#{APP_NAME}.ipa"
  end
  def build_url
    "https://circleci.com/gh/#{ENV['CIRCLE_PROJECT_USERNAME']}/#{ENV['CIRCLE_PROJECT_REPONAME']}/#{build_num}"
  end
  def build_num
    ENV['CIRCLE_BUILD_NUM']
  end
  def plist_url
    "https://#{ENV['S3_BUCKET']}.s3.amazonaws.com/#{upload_path}/app.plist"
  end
  def icon_url
    ENV['ICON_URL']
  end
  def bundle_identifier
    plist_print :CFBundleIdentifier
  end
  def bundle_version
    plist_print :CFBundleVersion
  end
  def title
    APP_NAME
  end
  def acl
    'public-read'
  end
  def upload
    s3_upload "#{ADHOC_DIR}/#{name}"
  end
end

namespace :adhoc do
  desc 'Generate AdHoc Distribution Page'
  task :page do
    %w{index.html app.plist}.each do|file|
      IO.write "#{ADHOC_DIR}/#{file}", AdHocPage.new(file).render
    end
  end
  task :upload => [:page] do
    AdHocPage.new('app.plist').upload
    page = AdHocPage.new('index.html')
    page_url = page.upload
    %x{./Scripts/slack-notify.sh "<#{page_url}|*Build #{page.bundle_version}*> is available :iphone:"}
  end
end
