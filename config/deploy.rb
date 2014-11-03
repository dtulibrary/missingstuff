require 'bundler/capistrano'

if(variables.include?(:environment))
  set :rails_env, "#{environment}"
else
  set :rails_env, "unstable"
end

if(variables.include?(:host))
  set :application, "#{host}"
else
  set :application, 'missingstuff.vagrant.vm'
end

set :deploy_to, "/var/www/#{application}"
role :web, "#{application}"
role :app, "#{application}"
role :db, "#{application}", :primary => true

default_run_options[:pty] = true

ssh_options[:forward_agent] = false
set :user, 'capistrano'
set :use_sudo, false
set :copy_exclude, %w(.git jetty feature spec vagrant)

if fetch(:application).end_with?('vagrant.vm')
  set :scm, :none
  set :repository, '.'
  set :deploy_via, :copy
  set :copy_strategy, :export
  ssh_options[:keys] = [ENV['IDENTITY'] || './vagrant/puppet-applications/vagrant-modules/vagrant_capistrano_id_dsa']
else
  set :deploy_via, :remote_cache
  set :scm, :git
  if(variables.include?(:scm_user))
    set :scm_username, "#{scm_user}"
  else
    set :scm_username, "#{user}"
  end
  set :repository, "#{scm_url}"
  if variables.include?(:branch_name)
    set :branch, "#{branch_name}"
  else
    set :branch, 'master'
  end
  set :git_enable_submodules, 1
end

# tasks

before "deploy:assets:precompile", "config:symlink"
before "deploy:assets:precompile", "config:solr"

namespace :config do
  desc "linking configuration to current release"
  task :symlink do
    %w(secrets.yml application.local.rb database.yml solr.yml fedora.yml role_map.yml).each do |f|
      run "ln -nfs #{deploy_to}/shared/config/#{f} #{release_path}/config/#{f}"
    end
  end

  desc "copying solr config in place and restart tomcat if necessary"
  task :solr do
    diff = ""
    %w(solrconfig.xml schema.xml).each do |f|
      diff << file_diff = capture("diff -q #{release_path}/solr_conf/conf/#{f} /var/lib/solr/core/conf/#{f} || true")
      run "cp #{release_path}/solr_conf/conf/#{f} /var/lib/solr/core/conf/#{f}" if !file_diff.strip.empty?
    end
    run 'sudo /etc/init.d/tomcat7 restart' if !diff.strip.empty?
  end

end

# load deploy:seed task
load 'lib/deploy/seed'

namespace :deploy do
  task :start, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end

  task :stop, :roles => :app do
    # Do nothing.
  end

  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end
end
