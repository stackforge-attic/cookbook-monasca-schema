# Temporary way of loading in the mysql schema

bash 'mon_schema' do
  action :nothing
  code 'mysql -uroot -ppassword < /var/lib/mysql/mon.sql'
end

cookbook_file '/var/lib/mysql/mon.sql' do
  action :create
  owner 'root'
  group 'root'
  source 'mysql/mon.sql'
  notifies :run, "bash[mon_schema]"
end
