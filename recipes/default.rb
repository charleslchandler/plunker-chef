#
# Cookbook Name:: plunker
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

require_recipe 'plunker::prereqs'

username  = node['plunker']['username']
groupname = node['plunker']['groupname']
conf_dir  = node['plunker']['conf_dir']

group groupname
user  username do
  group groupname
end

directory conf_dir do
  user   username
  group  groupname
  mode   "0755"
  action :create
end

package 'git'
