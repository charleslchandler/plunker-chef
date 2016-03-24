#
# Cookbook Name:: plunker
# Recipe:: api
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

require_recipe 'plunker::default'

package 'mongodb'

username    = node['plunker']['mongodb']['username']
password    = node['plunker']['mongodb']['password']
database    = node['plunker']['mongodb']['database']
db_host     = "localhost"
basedir     = node['plunker']['www_root']
destdir     = File.join(basedir, 'plunker_api')
fqdn        = "#{node['hostname']}.#{node['dns']['domain']}"
#fqdn        = 'localhost'
conf_file   = '/etc/plunker/config.api.json'
task_name   = "plunker-api"
node_env    = "development"

execute 'add user to mongodb' do
  command "mongo #{database} --eval 'db.addUser(\"#{username}\", \"#{password}\")'"
end

template conf_file do
  source 'config.api.json.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables({
    embed_server_fqdn: fqdn,
    embed_server_port: node['plunker']['embed']['port'],
    www_server_fqdn: fqdn,
    www_server_port: node['plunker']['www']['port'],
    collab_server_fqdn: fqdn,
    collab_server_port: node['plunker']['collab']['port'],
    api_server_fqdn: fqdn,
    api_server_port: node['plunker']['api']['port'],
    run_server_fqdn: fqdn,
    run_server_port: node['plunker']['run']['port'],
    github_client_id: node['plunker']['github']['client_id'],
    github_client_secret: node['plunker']['github']['client_secret'],
    protocol: node['plunker']['protocol'],
    mongodb_fqdn: db_host,
    mongodb_port: node['plunker']['mongodb']['port'],
    mongodb_user: username,
    mongodb_password: password,
    mongodb_db: database
  })
  action :create
end

include_recipe 'tarball::default'

username      = 'root'
tarball       = "plunker_api.tgz"
tmp_tb        = "/tmp/#{tarball}"

cookbook_file tmp_tb do
  source tarball
  owner username
  group username
  mode '0644'
  action :create
end

tarball tmp_tb do
  destination basedir
  owner username
  group username
  umask 002
  action :extract
  not_if "test -d #{destdir}"
end

execute 'install npm packages locally' do
  command "npm install"
  cwd destdir
end

link "#{destdir}/config.development.json" do
  to conf_file
end

link "#{destdir}/config.production.json" do
  to conf_file
end

#execute 'generate initd entry' do
#  command "initd-forever -a #{destdir}/server.js && cp ./#{task_name} /etc/init.d/#{task_name} && chmod a+rx /etc/init.d/#{task_name}"
#  cwd destdir
#end

template "/etc/init.d/#{task_name}" do
  source 'forever-rc.erb'
  owner 'root'
  group 'root'
  mode '0755'
  variables({
    task_name: task_name,
    app_root:  destdir,
    node_env:  node_env
  })
  action :create
end

service task_name do
  action [:enable, :start]
end
