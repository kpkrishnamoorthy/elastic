Pre-requisites
==============
An AWS access key and secret that provides sufficient privileges to:

=> Create VPCs and associated network objects, such as Internet gateways, subnets, security groups and route tables.

=> Launch instances

Launching an ElasticSearch cluster
==================================

=> Check out this repository to a folder on your machine

=> From within the repo's root folder, run 'bundle install'

=> From within the repo's root folder, run 'ruby scripts/launch.rb'

=> When prompted, enter your AWS access key and secret.

=> After the script completes running, you can access kopf at http://<public_ip>:9200/_plugin/kopf - where <public_ip> is the public IP of any of the 3 VMs that were launched by the script.

Caveats
=======

=> Note that this script is NOT designed to be run twice - it will create duplicate resources, and cluster nodes will not be able to see each other across each run. However, the Chef recipes will think that all nodes can see each other, which will lead to errors.

=> If instances are terminated on AWS without deleting Chef node resources, `/etc/elasticsearch/elasticsearch.yml` will contain invalid host IP addresses on a succeeding run of the script. Only valid nodes should remain on the Chef server.
