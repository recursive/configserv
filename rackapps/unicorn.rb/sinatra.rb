# Set up unicorn variables
APP_ROOT = File.expand_path(File.dirname(File.dirname(__FILE__)))
RACK_ENV ||= 'none'

# Needed for some directory creation later
require 'fileutils'

# Setup paths
log_path = APP_ROOT + "/log"
tmp_path = APP_ROOT + "/tmp"

[log_path, tmp_path].each { |d| FileUtils.mkdir(d) unless File.directory?(d) }

# Check for RVM for companability
if ENV['MY_RUBY_HOME'] && ENV['MY_RUBY_HOME'].include?('rvm')
  begin
    rvm_path = File.dirname(File.dirname(ENV['MY_RUBY_HOME']))
    rvm_lib_path = File.join(rvm_path, 'lib')
    $LOAD_PATH.unshift rvm_lib_path
    require 'rvm'
    RVM.use_from_path! APP_ROOT
  rescue LoadError
    raise "RVM ruby lib is currently unavailable."
  end
end

# Set the BUNDLE_GEMFILE env variable and require bundler
ENV['BUNDLE_GEMFILE'] = File.expand_path('../Gemfile', File.dirname(__FILE__))
require 'bundler/setup'

# Unicorn setup
worker_processes 4
working_directory APP_ROOT

preload_app true

timeout 30

# Set up unicorn data
listen tmp_path + "/unicorn.sock", :backlog => 64
pid tmp_path + "/unicorn.pid"

# Set log files
stderr_path log_path + "/unicorn.stderr.log"
stdout_path log_path + "/unicorn.stdout.log"

before_fork do |server, worker|
  old_pid = APP_ROOT + '/tmp/unicorn.pid.oldbin'
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      puts "Old master alerady dead"
    end
  end
end