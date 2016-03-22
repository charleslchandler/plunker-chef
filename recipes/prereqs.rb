#
# Cookbook Name:: plunker
# Recipe:: prereqs
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

package 'python-software-properties'
package 'python'
package 'g++'
package 'make'
package 'nodejs'

execute 'install npm-forever' do
  command "npm install -g forever"
end

execute 'install initd-forever' do
  command "npm install -g initd-forever"
end
