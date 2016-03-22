#
# Cookbook Name:: plunker
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

require_recipe 'plunker::prereqs'

username  = "plunker"
groupname = "plunker"

group groupname
user  username do
  group groupname
end

directory "/etc/plunker" do
  user   "root"
  group  "root"
  mode   "0755"
  action :create
end
