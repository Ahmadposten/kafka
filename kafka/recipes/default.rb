#
# Cookbook Name:: kafka
# Recipe:: default
#
# Copyright 2011, Heavy Water Operations, LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
::Chef::Recipe.send(:include, ChefKafka::Helpers)

node.default[:kafka][:config]["#{kafka_zk_prefix}.connectiontimeout.ms"] = 1000000

include_recipe "zookeeper"
include_recipe "kafka::discovery" if node[:kafka][:auto_discovery]

version_dir = "kafka-#{node[:kafka][:version]}"
base_dir = File.join(node[:kafka][:install_dir], version_dir)
extracted_path = kafka_suffix_cwd(node[:kafka][:download_url])
build_commands = []

build_commands << "tar xfz kafka_#{node[:scala][:version]}-#{node[:kafka][:version]}.tgz -C /opt"
build_commands << "chown -R #{node[:kafka][:user]}:#{node[:kafka][:group]} #{base_dir}"

node.default[:kafka][:build_commands] = build_commands

group node[:kafka][:group]

apt_update
apt_package %w(default-jre)

directory node[:kafka][:install_dir] do
  recursive true
end

user node[:kafka][:user] do
  comment 'Kafka user'
  gid node[:kafka][:group]
  supports :manage_home => true
  home node[:kafka][:install_dir]
  shell node[:kafka][:shell]
  system true
end

directory base_dir do
  recursive true
  user node[:kafka][:user]
  group node[:kafka][:group]
end

directory node[:kafka][:conf_dir] do
  recursive true
end

directory node[:kafka][:log_dir] do
  recursive true
  user node[:kafka][:user]
  group node[:kafka][:group]
end

builder_remote version_dir do
  remote_file node[:kafka][:download_url]
  suffix_cwd extracted_path
  commands node[:kafka][:build_commands]
  creates File.join(base_dir, "bin/kafka-server-start.sh")
end

link "#{node[:kafka][:install_dir]}/kafka" do
  to base_dir
  owner node[:kafka][:user]
  group node[:kafka][:group]
end

runit_service "kafka" do
  finish true
end

node.default[:kafka][:config]["log.dir"] = node[:kafka][:log_dir]

if node[:kafka][:config][kafka_broker_key].nil?
  node.default[:kafka][:config][kafka_broker_key] = new_kafka_broker_id
end

template File.join(node[:kafka][:conf_dir], 'kafka.properties') do
  source 'kafka.properties.erb'
  mode 0644
  notifies :restart, 'service[kafka]', :delayed
end

run_class_template = nil
server_start_template = nil

if !run_class_template.nil?
  template File.join(node[:kafka][:install_dir], '/kafka/bin/kafka-run-class.sh') do
    source run_class_template
    mode 0755
    owner node[:kafka][:user]
    group node[:kafka][:group]
    variables ({
      :jmx_opts => node[:kafka][:jmx_opts]
    })
    notifies :restart, 'service[kafka]', :delayed
  end
end

if !server_start_template.nil? && node[:kafka][:jmx_port]
  template File.join(node[:kafka][:install_dir], '/kafka/bin/kafka-server-start.sh') do
    source server_start_template
    mode 0755
    owner node[:kafka][:user]
    group node[:kafka][:group]
    variables ({
      :jmx_port => node[:kafka][:jmx_port]
    })
    notifies :restart, 'service[kafka]', :delayed
  end
end

service 'kafka' do
  action :nothing
end
