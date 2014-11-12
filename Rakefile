require 'rubygems/version'
require 'rake/clean'
require 'date'
require 'dotenv/tasks'
require 'command-builder'
require 'base64'

APP_NAME = "CI2Go"
SDK = "iphoneos"
WORKSPACE = File.expand_path "#{APP_NAME}.xcworkspace"
CERTIFICATES_PATH = File.expand_path 'Certificates'
PROFILES_PATH = File.expand_path 'MobileProvisionings'
BUILD_DIR = File.expand_path 'build'
KEYCHAIN_NAME = 'ios-build.keychain'

CLEAN.include BUILD_DIR, PROFILES_PATH, CERTIFICATES_PATH, 'CI2Go/Environment.swift'
CLOBBER.include BUILD_DIR, PROFILES_PATH, CERTIFICATES_PATH, 'CI2Go/Environment.swift'

class CommandBuilder
  def system!
    system to_s
    exit $?.exitstatus if $?.exitstatus > 0
  end
end

class InfoPlist
  attr_accessor :file

  def initialize file
    @file = file
  end

  def [](key)
    output = %x[/usr/libexec/PlistBuddy -c "Print #{key}" #{file}].strip
    raise "The key `#{key}' does not exist in `#{file}'." if output.include?('Does Not Exist')
    output
  end

  def set(key, value, file = "#{file}")
    %x[/usr/libexec/PlistBuddy -c 'Set :#{key} "#{value}"' '#{file}'].strip
  end
  def []=(key, value)
    set(key, value)
  end

  def build_version
    self['CFBundleVersion']
  end
  def build_version=(revision)
    self['CFBundleVersion'] = revision
  end

  def marketing_version
    self['CFBundleShortVersionString']
  end
  def marketing_version=(version)
    self['CFBundleShortVersionString'] = version
  end

  def marketing_and_build_version
    "#{marketing_version} (#{build_version})"
  end

  def bump_minor_version
    segments = Gem::Version.new(marketing_version).segments
    segments[1] = "%02d" % (segments[1].to_i + 1)
    version = segments.join('.')
    self.marketing_version = version
    segments[1]
  end

  def bump_major_version
    segments = Gem::Version.new(marketing_version).segments
    segments[0] = segments[0].to_i + 1
    segments[1] = "00"
    version = segments.join('.')
    self.marketing_version = version
    segments[0]
  end

  def bump_release_version
    if bump_minor_version.to_i.odd?
      bump_minor_version
    end
  end

  def update_build_number
    n = ENV['TRAVIS_BUILD_NUMBER'] || %x{git rev-parse --short HEAD}.strip
    self.build_version = n
  end

  def self.commit
    system("git commit #{mainInfoPlist.file} #{widgetInfoPlist} -m 'Bump to #{marketing_and_build_version}'")
  end
end

def repo_slug
  ENV['TRAVIS_REPO_SLUG'] || %x{git config remote.origin.url}.strip.match(%r{([^\/:]+/.+)\.git$})[1]
end

def repo_url
  "https://github.com/#{repo_slug}"
end

def branch_url
  "#{repo_url}/commit/#{branch_name}"
end

def pull_request_url
  pr_number ? "#{repo_url}/pull/#{pr_number}" : nil
end

def bundle_exec command, args = {}
  cmd = CommandBuilder.new :bundle, ['-', ' ', '--', ' ']
  cmd << 'exec'
  command = command.to_s.split ' ' unless command.is_a? Array
  command.each{|c| cmd << c.to_s }
  args.each {|k, v| cmd[k.to_sym] = v }
  cmd
end

def scheme
  APP_NAME
end

def branch_name
  ENV['TRAVIS_BRANCH'] || %x{git rev-parse --abbrev-ref HEAD}.strip
end

def commit_hash
  ENV['TRAVIS_COMMIT'] || %x{git rev-parse HEAD}.strip
end

def ipa_file
  File.join BUILD_DIR, "#{scheme}.ipa"
end

def dsym_archive
  File.join BUILD_DIR, "#{scheme}.app.dSYM.zip"
end

def production?
  (ENV['TRAVIS_TAG'] || '').match(/^v\d+\.\d+\.\d+/) || ENV['DISTRIBUTE_ITUNES_CONNECT']
end

def pr_number
  ENV["TRAVIS_PULL_REQUEST"]
end

def pull_request?
  !(pr_number || '').match(/^\d+$/).nil?
end

def provisioning_profile
  "#{PROFILES_PATH}/#{scheme}#{production? ? 'Distribution' : 'AdHoc'}"
end

def apple_password
  Base64.decode64(ENV['APPLE_PASSWORD']).strip
end

def cupertino command, args = {}
  bundle_exec([:ios, command], args.merge(
    username: ENV['APPLE_USER'],
    password: apple_password
  )).system!
end

def shenzhen command, args = {}
  cmd = bundle_exec :ipa
  if ENV['VERBOSE']
    cmd << :trace
    cmd << :verbose
  end
  cmd << command.to_s
  args.each {|k, v| cmd[k.to_sym] = v }
  cmd.system!
end

def security command, args = {}, keychain_name = nil
  cmd = CommandBuilder.new :security
  command = command.to_s.split ' ' unless command.is_a? Array
  command.each {|c| cmd << c.to_s }
  args.each {|k, v| cmd[k.to_sym] = v }
  cmd << keychain_name.to_s unless keychain_name.nil?
  cmd.system!
end

def xctool command, args = {}
  cmd = CommandBuilder.new :xctool, '- - '.split('')
  command = command.to_s.split ' ' unless command.is_a? Array
  args = {
    scheme: 'CI2GoTests',
    workspace: WORKSPACE,
    sdk: 'iphonesimulator',
    configuration: 'Debug'
  }.merge args
  args.each {|k, v| cmd[k.to_sym] = v }
  command.each {|c| cmd << c.to_s }
  cmd.system!
end

def release_notes
  release_date = DateTime.now.strftime("%Y/%m/%d %H:%M:%S")
  build_version = mainInfoPlist.marketing_and_build_version
  res = <<RELEASENOTE
Build: #{build_version}
Uploaded: #{release_date}
Branch: #{branch_url}

RELEASENOTE

  if pull_request?
    res << "Pull Request: #{pull_request_url}\n"
    res << %x[git log --date=short --pretty=format:"* %h - %s (%cd) <%an>" --no-merges #{branch_name}..]
  elsif branch_name == "master"
    res << %x[git log --date=short --pretty=format:"* %h - %s (%cd) <%an>" --no-merges $(git describe --abbrev=0 --tags)..]
  else
    res << %x[git log --date=short --pretty=format:"* %h - %s (%cd) <%an>" --no-merges]
  end

  res
end

def mainInfoPlist
  @mainInfoPlist ||= InfoPlist.new File.expand_path "#{APP_NAME}/Info.plist"
end

def widgetInfoPlist
  @widgetInfoPlist ||= InfoPlist.new File.expand_path "#{APP_NAME}Widget/Info.plist"
end

desc 'Print release notes'
task :releasenotes do
  puts release_notes
end

namespace :version do
  desc 'Print current version'
  task :current do
    puts mainInfoPlist.marketing_and_build_version
  end

  namespace :update do
    desc 'Update build number'
    task :build do
      mainInfoPlist.update_build_number
      widgetInfoPlist.update_build_number
    end
  end

  namespace :bump do
    desc 'Bump minor version (0.XX)'
    task :minor => :'version:update:build' do
      mainInfoPlist.bump_minor_version
      widgetInfoPlist.bump_minor_version
      InfoPlist.commit
    end

    desc 'Bump major version (X.00)'
    task :major => :'version:update:build' do
      mainInfoPlist.bump_major_version
      widgetInfoPlist.bump_major_version
      InfoPlist.commit
    end

    desc 'Bump release version (0.XY)'
    task :release => :'version:update:build' do
      mainInfoPlist.bump_release_version
      widgetInfoPlist.bump_release_version
      InfoPlist.commit
    end
  end

end

namespace :pod do
  desc 'Install CocoaPods libraries'
  task :install => :dotenv do
    require 'cocoapods'
    Pod::Command.run %w{install --no-integrate}
  end
end

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

desc 'Run tests'
task :test => :'test:build' do
  xctool :test
end

namespace :test do
  desc 'Build tests'
  task :build => :'env:export' do
    xctool :build
  end
end

namespace :ipa do
  desc 'Build .ipa file'
  task :build => :'env:export' do
    shenzhen :build, {
      workspace: WORKSPACE,
      configuration: 'Release',
      scheme: scheme,
      sdk: 'iphoneos',
      destination: BUILD_DIR,
      embed: provisioning_profile
    }
  end
  namespace :distribute do
    desc 'Publish .ipa file to Amazon S3'
    task :s3 => :dotenv do
      shenzhen 'distribute:s3', {
        file: ipa_file,
        dsym: dsym_archive,
        bucket: ENV['S3_IPA_BUCKET'],
        path: "#{scheme}/{CFBundleShortVersionString}/#{ production? ? 'distribute' : 'adhoc' }/{CFBundleVersion}",
        'source-dir' => BUILD_DIR,
      }
    end
    desc 'Publish .ipa file to TestFlight'
    task :testflight => :dotenv do
      if production?
        puts 'Skipping TestFlight for production'
      else
        shenzhen 'distribute:testflight', {
          file: ipa_file,
          dsym: dsym_archive,
          replace: nil,
          lists: pull_request? ? 'CI2Go-Dev' : 'CI2Go-Testers',
          notes: release_notes
        }
      end
    end
    desc 'Publish .ipa file to iTunes Connect'
    task :itunesconnect => :dotenv do
      shenzhen 'distribute:itunesconnect', {
        file: ipa_file,
        account: ENV['APPLE_USER'],
        password: apple_password,
        upload: nil,
        warnings: nil,
        errors: nil,
      }
    end
  end
end

namespace :profiles do
  desc 'Download all mobileprovision files'
  task :download => :clean do
    mkpath PROFILES_PATH
    Dir.chdir(PROFILES_PATH) do
      cupertino 'profiles:download:all', type: :distribution
    end
  end
  desc 'Install mobileprovision files'
  task :install => :dotenv do
    ENV['PROVISIONING_SUFFIX'] = production? ? 'Distribution' : 'AdHoc'
    cmd = CommandBuilder.new :'/bin/sh'
    cmd << File.expand_path('Scripts/install-mobileprovisioning.sh')
    cmd.system!
  end
  desc 'Clean mobileprovision files'
  task :clean => :dotenv do
    rmtree PROFILES_PATH
  end
end

namespace :certificate do
  def s3path
    "#{ENV['S3_CERTIFICATE_BUCKET']}:"
  end
  def sync src, dest
    bundle_exec([:s3sync, :sync, src, dest]).system!
  end
  desc 'Download certificates from S3'
  task :download => :dotenv do
    sync s3path, CERTIFICATES_PATH
  end
  desc 'Upload certificates from S3'
  task :upload => :dotenv do
    sync CERTIFICATES_PATH, s3path
  end
  desc 'Add certificates'
  task :add => :download do
    def import_file file, args = {}
      security ['import', file], {
        k: KEYCHAIN_NAME,
        A: nil,
        T: '/usr/bin/codesign'
      }.merge(args)
    end
    keychains = %x{security list-keychains}.gsub(/[\n"]/, "").strip.split(/[\s]+/)
    unless keychains.include? File.expand_path("~/Library/Keychains/#{KEYCHAIN_NAME}")
      security 'create-keychain', { p: ENV['KEYCHAIN_PASSWORD'] }, KEYCHAIN_NAME
    end
    Dir.glob("#{CERTIFICATES_PATH}/*.cer"){|c| import_file c }
    Dir.glob("#{CERTIFICATES_PATH}/*.p12"){|c| import_file c, P: ENV['CERTIFICATE_PASSPHRASE'] }
    security 'default-keychain', s: KEYCHAIN_NAME
    security 'unlock-keychain', { p: ENV['KEYCHAIN_PASSWORD'] }, KEYCHAIN_NAME
  end
  desc 'Remove certificates'
  task :remove => :dotenv do
    security 'delete-keychain', {}, KEYCHAIN_NAME
  end
end

task :setup => [:'version:update:build', :'env:export', :'certificate:download', :'certificate:add', :'profiles:download', :'profiles:install', :'pod:install']
task :distribute => [:'ipa:build', :'ipa:distribute:s3', :'ipa:distribute:testflight']
desc 'Print current version'
task :version => 'version:current'
