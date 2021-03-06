require "rvm/capistrano"
require "bundler/capistrano"
require "sidekiq/capistrano"
# require "cap_tasks"

server "208.68.38.93", :web, :app, :db, primary: true

set :application, "triangleror"
set :user, "deployer"
set :deploy_to, "/home/#{user}/apps/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false

set :scm, "git"
set :repository, "git@github.com:MichaelCPell/#{application}.git"
set :branch, "master"

set :rvm_ruby_string, 'ruby-1.9.3-p385'
set :rvm_type, :system

set :sidekiq_cmd, "bundle exec sidekiq"
set :sidekiqctl_cmd, "bundle exec sidekiqctl"
set :sidekiq_timeout, 10
set :sidekiq_role, :app
set :sidekiq_pid, "#{current_path}/tmp/pids/sidekiq.pid"
set :sidekiq_processes, 1


default_run_options[:pty] = true
ssh_options[:forward_agent] = true

after "deploy", "deploy:cleanup" # keep only the last 5 releases

namespace :deploy do
  %w[start stop restart].each do |command|
    desc "#{command} unicorn server"
    task command, roles: :app, except: {no_release: true} do
      run "/etc/init.d/unicorn_#{application} #{command}"
    end
  end

  task :start_redis,   except: {no_release: true} do
    run "redis-server"
  end

  task :setup_config, roles: :app do
    sudo "ln -nfs #{current_path}/config/nginx.conf /etc/nginx/sites-enabled/#{application}"
    sudo "ln -nfs #{current_path}/config/unicorn_init.sh /etc/init.d/unicorn_#{application}"
    run "mkdir -p #{shared_path}/config"
    put File.read("config/database.yml"), "#{shared_path}/config/database.yml"
    puts "Now edit the config files in #{shared_path}."
  end
  after "deploy:setup", "deploy:setup_config"

  task :symlink_config, roles: :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
  after "deploy:finalize_update", "deploy:symlink_config"

  desc "Make sure local git is in sync with remote."
  task :check_revision, roles: :web do
    unless `git rev-parse HEAD` == `git rev-parse origin/master`
      puts "WARNING: HEAD is not the same as origin/master"
      puts "Run `git push` to sync changes."
      exit
    end
  end
  before "deploy", "deploy:check_revision"

  task :migrate_and_seed_fu do
    run("cd #{deploy_to}/current && bundle exec rake db:migrate RAILS_ENV=#{rails_env}")
    run("cd #{deploy_to}/current && bundle exec rake db:seed_fu RAILS_ENV=#{rails_env}")
  end

  task :start_sidekiq,roles: :app, except: {no_release: true} do
      run %{ssh deployer@208.68.38.93 -o StrictHostKeyChecking=no -t "#{default_shell} -c 'cd #{current_path} && bundle exec sidekiq -e production'"}
  end

end

desc "tail production log files" 
task :tail_logs, :roles => :app do
  run "tail -f #{shared_path}/log/production.log" do |channel, stream, data|
    puts  # for an extra line break before the host name
    puts "#{channel[:host]}: #{data}" 
    break if stream == :err    
  end
end

desc "Remote console" 
task :console, :roles => :app do
  exec %{ssh deployer@208.68.38.93 -t "#{default_shell} -c 'cd #{current_path} && bundle exec rails c #{rails_env}'"}
end


