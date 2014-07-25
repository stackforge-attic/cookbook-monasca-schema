#!/bin/sh -xe
#
# Build the mon data base

if [ $USER != 'dbadmin' ]; then
  echo "Must be run by the dbadmin user"
  exit
fi

# Make sure the locale settings are set correctly
. /etc/profile.d/vertica_node.sh

# Pull comma seperated list of nodes from the config
nodes=`grep install_opts /opt/vertica/config/admintools.conf | cut -d\  -f 6 |cut -d\' -f 2`

# create the db
/opt/vertica/bin/admintools -t create_db -s $nodes -d mon -p password

# Add in the schemas
/opt/vertica/bin/vsql -w password < /var/vertica/mon_schema.sql
/opt/vertica/bin/vsql -w password < /var/vertica/mon_metrics_schema.sql
/opt/vertica/bin/vsql -w password < /var/vertica/mon_alarms_schema.sql
/opt/vertica/bin/vsql -w password < /var/vertica/mon_users.sql
/opt/vertica/bin/vsql -w password < /var/vertica/mon_grants.sql

# Set restart policy to ksafe
/opt/vertica/bin/admintools -t set_restart_policy -d mon -p ksafe

# For ssl support link the cert/key on each server and restart the db
IFS=','
for node in $nodes do
  ssh $node 'ln -s /var/vertica/server* /var/vertica/catalog/mon/v*/'
done

/opt/vertica/bin/admintools -t stop_db -F -p password -d mon
/opt/vertica/bin/admintools -t start_db -p password -d mon
