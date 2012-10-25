# encoding: UTF-8
require 'pathname'

APP_ROOT  = Pathname.new(File.dirname(File.expand_path __FILE__)).join('..')
rails_env = ENV['RAILS_ENV'] || 'development'

working_directory APP_ROOT.to_s
preload_app true
timeout 30

# Start 4 workers in prod, and just half this in development.
if rails_env == 'production'
  worker_processes 4
  listen "#{ APP_ROOT }/tmp/sockets/unicorn.sock", backlog: 64
else
  worker_processes 2
  listen 3000, tcp_nopush: true
end

pid "#{ APP_ROOT }/tmp/pids/unicorn.pid"
stderr_path "#{ APP_ROOT }/log/unicorn.stderr.log"
stdout_path "#{ APP_ROOT }/log/unicorn.stdout.log"
