# encoding: UTF-8#
#
# Lays down a db creation script and default schema

# There is a bug where $HOME is not set currectly for exec, I use sudo to
# avoid this https://tickets.opscode.com/browse/CHEF-2288
bash 'create_mon_db' do
  action :nothing
  user 'root'
  code <<-EOH
  ulimit -n 65536  # Max files open limit must be set for db creation to work.
  sudo -Hu dbadmin /var/vertica/create_mon_db.sh
  EOH
end

# Note: As projections based on k-safety are added this file list will need
# modification based on a clustered or not setup
%w[ mon_grants.sql mon_schema.sql mon_metrics_schema.sql
    mon_alarms_schema.sql mon_users.sql ].each do |filename|
  cookbook_file "/var/vertica/#{filename}" do
    action :create
    source "vertica/#{filename}"
    owner node[:vertica][:dbadmin_user]
    group node[:vertica][:dbadmin_group]
    mode '644'
  end
end

if node.default[:vertica][:cluster]
  setup_script = 'create_mon_db_cluster.sh'
else
  setup_script = 'create_mon_db.sh'
end

cookbook_file '/var/vertica/create_mon_db.sh' do
  action :create
  source "vertica/#{setup_script}"
  owner node[:vertica][:dbadmin_user]
  group node[:vertica][:dbadmin_group]
  mode '755'
  notifies :run, 'bash[create_mon_db]'
end
