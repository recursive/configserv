APP_ROOT = File.expand_path(File.dirname(File.dirname(__FILE__)))

ENV['RAILS_ENV'] ||= 'production'

require 'fileutils'
%w{/log /tmp /tmp/pids /tmp/sessions /tmp/sockets /tmp/cache}.each do |d|
  FileUtils.mkdir(APP_ROOT + d) unless File.directory?(APP_ROOT + d)
end

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

ENV['BUNDLE_GEMFILE'] = File.expand_path('../Gemfile', File.dirname(__FILE__))
require 'bundler/setup'

worker_processes 4
working_directory APP_ROOT
preload_app true
timeout 30
listen APP_ROOT + "/tmp/sockets/unicorn.sock", :backlog => 64
pid APP_ROOT + "/tmp/pids/unicorn.pid"
stderr_path APP_ROOT + "/log/unicorn.stderr.log"
stdout_path APP_ROOT + "/log/unicorn.stdout.log"

before_fork do |server, worker|
  old_pid = RAILS_ROOT + '/tmp/pids/unicorn.pid.oldbin'
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      puts "Old master alerady dead"
    end
  end
end