#
# Cookbook Name:: microsoft_azure_expanded
# Recipe:: default
#
# Copyright 2015, Vapok, Inc.
#
# All rights reserved - Do Not Redistribute
#

# FIXME must force macaddr version to workaround systemu conflict
chef_gem 'macaddr' do
  action :remove
  not_if "/opt/chef/embedded/bin/gem list macaddr | grep \"(#{node['microsoft_azure']['macaddr_version']})\""
end

chef_gem 'macaddr' do
  version node['microsoft_azure']['macaddr_version']
  action :install
end

chef_gem 'azure' do
  version node['microsoft_azure']['azure_gem_version']
  action :install
end

require 'azure'