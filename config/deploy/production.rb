# config valid only for current version of Capistrano
lock '3.4.0'

server 'hostname', roles: [:web, :app, :db], primary: true

set :repo_url,        ''
set :application,     ''
set :user,            ''

set :stage,           :production
set :scm,             :git
set :branch,          :master

set :passenger_restart_with_touch, true

set :pty,             true
set :use_sudo,        false
set :deploy_via,      :remote_cache
set :deploy_to,       "/path/to/app/#{fetch(:application)}"
set :ssh_options,     { forward_agent: true, user: fetch(:user) }

namespace :deploy do
  desc "Make sure local git is in sync with remote."
  task :check_revision do
    on roles(:app) do
      unless `git rev-parse HEAD` == `git rev-parse origin/master`
        puts "WARNING: HEAD is not the same as origin/master"
        puts "Run `git push` to sync changes."
        exit
      end
    end
  end

  before :starting,     :check_revision
  after  :finishing,    :compile_assets
  after  :finishing,    :cleanup
  after  :finishing,    :restart
end
