-- Tune the DB
SELECT SET_CONFIG_PARAMETER ('MaxClientSessions', 200);
-- Turn off messages in the log created by the load balancer/icinga checks
SELECT set_config_parameter('WarnOnIncompleteStartupPacket', 0);

-- Enable SSL ** Requires a db restart, also the restart will fail of the ssl cert is not in place on the server
-- The certs are placed in the root catalog dir by vertica and should be linked to the correct dir after db creation
-- ln /var/vertica/catalog/server* /var/vertica/catalog/mon/v*/'
SELECT SET_CONFIG_PARAMETER('EnableSSL', '1');

-- Enable SNMP alerts
SELECT SET_CONFIG_PARAMETER('SnmpTrapsEnabled', 1 );
SELECT SET_CONFIG_PARAMETER('SnmpTrapEvents', 'Low Disk Space, Read Only File System, Loss Of K Safety, Current Fault Tolerance at Critical Level, Too Many ROS Containers, WOS Over Flow, Node State Change, Recovery Failure, Recovery Error, Recovery Lock Error, Recovery Projection Retrieval Error, Refresh Error, Tuple Mover Error, Stale Checkpoint');
-- Set the snmp trap destination, the host name for the appropriate icinga server should be filled in before the port, ie
-- SELECT SET_CONFIG_PARAMETER('SnmpTrapDestinationsList', 'ops-aw1rdd1-monitoring0000.rndd.aw1.hpcloud.net 162 public' );

-- Set the WOS size large to handle lots of inserts and give it a dedicated bit of space so inserts can be constant,
-- The catch is every moveout makes a ROS and we quickly get lots of partitions, mergeouts are slow but keep partitions down
SELECT do_tm_task('moveout'); -- Do a moveout as the memory sizes won't change with active transactions.
ALTER RESOURCE POOL wosdata memorysize '250M' maxmemorysize '5G'; -- default 0 and 2GB 
ALTER RESOURCE POOL tm plannedconcurrency 2 maxconcurrency 4; -- default 1 and 2 
SELECT SET_CONFIG_PARAMETER ('MoveOutSizePct', 75); -- default 0
SELECT SET_CONFIG_PARAMETER ('MoveOutInterval', 300); -- default 300
SELECT SET_CONFIG_PARAMETER ('MergeOutInterval', 300); -- default 600

-- Create users
CREATE USER monitor IDENTIFIED BY 'password';
GRANT pseudosuperuser TO monitor; -- This is the only way I know to allow the monitor user to see some user permissions.
ALTER USER monitor DEFAULT ROLE pseudosuperuser;
