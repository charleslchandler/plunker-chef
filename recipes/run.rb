#
# Cookbook Name:: plunker
# Recipe:: run
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

require_recipe "plunker::default"

basedir     = node['plunker']['www_root']
destdir     = File.join(basedir, 'plunker_run')
fqdn        = "#{node['hostname']}.#{node['dns']['domain']}"
#fqdn        = 'localhost'
conf_file   = '/etc/plunker/config.run.json'
task_name   = "plunker-run"
node_env    = "development"

template conf_file do
  source 'config.run.json.erb'
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
    protocol: node['plunker']['protocol'],
    github_client_id: node['plunker']['github']['client_id'],
    github_client_secret: node['plunker']['github']['client_secret']
  })
  action :create
end

include_recipe 'tarball::default'

username      = 'root'
tarball       = "plunker_run.tgz"
tmp_tb        = "/tmp/#{tarball}"

cookbook_file tmp_tb do
  source tarball
  # checksum sha256
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
