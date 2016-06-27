# Encoding: utf-8
#
# Cookbook Name:: elasticsearch
# Recipe:: default
#

include_recipe 'chef-sugar'

# see README.md and test/fixtures/cookbooks for more examples!
elasticsearch_user 'elasticsearch'
elasticsearch_install 'elasticsearch' do
  type node['elasticsearch']['install_type'].to_sym # since TK can't symbol.
end

search(:node, "role:elasticsearch").each { |i| node.default['elasticsearch']['cluster_nodes'] << i['ipaddress'] }

elasticsearch_configure 'elasticsearch'
elasticsearch_service 'elasticsearch'

elasticsearch_plugin 'kopf' do
  url 'lmenezes/elasticsearch-kopf'
  action :install
end

service "elasticsearch" do
  action [:restart]
end
