WARNING!!

Monasca is now deployed via Ansible. This Chef cookbook project is no longer maintained and may be out of date. It will be moved to the StackForge attic soon.

#monasca_schema Cookbook
Used to setup schema for various monasca components.


## Recipes
- influxdb - Creates the db and users, no schema since influxdb is schemaless
- mysql - Creates database and schema
- vertica - Creates database and schema
