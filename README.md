# Run Moodle on Amazon AWS Opsworks (Chef 12 Linux)

Attempting to setup Moodle server on Opsworks
- Apache 2.4
- PHP 5.6
- Memcached (runs on 1st front-end web server)
- Amazon RDS (MySQL 5.7)
- App install from Github

This requires Amazon EFS (Elastic File System), which is currently only in 3 AWS regions.


## Setup

### Pre-req

#### VPC (Virtual network)

##### Setup
- 1. AWS Console > VPC > Start VPC Wizard
- 2. Select >
IP CIDR block:10.10.0.0/16
VPC name: Moodle-ops

Public subnet:*10.10.0.0/24
Subnet name:Public subnet
Subnet:Moodle Public subnet
Enable DNS hostnames:*Tes
Hardware tenancy: Default
Enable ClassicLink:*no
- 3.Navigate to Subnets in VPC Dashboard
- 4. Create Subnet
Name: Moodle Private Subnet
CIDR: 10.10.20.0/24

#### RDS (Database)

AWS->Services->RDS

Set up a t2.micro or t2.small RDS instance.
- Step 1: MySQL
- Step 2: Production MySQL or Dev (up to you)
- Step 3: 
-- DB Engine Version 5.7.latest
-- DB Instance Class: t2.micro will do for a small setup
-- Multi-AZ: Up to you
-- Storage type: SSD either
-- DB instance identifier etc: "Moodle" / Up to you, but note the details you enter
- Step 4:
-- VPC: Same as all others in this setup
-- Security group: moodle-opsworks-all
-- Parameter group: "Moodle"

Note: If you used triggers in your Moodle database, you will need to create an RDS 'parameter group' and set your RDS instance to use it
- Parameter groups -> new 
-- Family: mysql5.7
-- Name: "Moodle"
-- Edit parameters
-- log_bin_trust_function_creators => 1


#### ELB (Load balancer)

AWS->Services->EC2->Load balancers


Create load balancer
- Load balancer name: Moodle-ops
- Create LB Inside : Moodle-ops (or VPC name created above)
- Listener config:
-- HTTP80->HTTP80
-- HTTPS443->HTTP80
- Security groups:
-- Default VPC security group (?)
-- moodle-opsworks-all
-- moodle-opsworks-webserver
- Security settings
-- Either upload your SSL cert, or create one with ACM - it's easy
- Health check:
-- Ping path: /aws-up-check.php
- Instances: none yet
#####- Other Options: Default

#### EFS

Create an EFS volume. No special configuration required. Note the filesystem ID.
Subnet: Moodle Private Subnet

#### EC2 Security Groups: 

Create the following security groups in your target region and VPC:

- moodle-opsworks-all
-- ssh: from: your IP
-- all traffic: from security group: moodle-opsworks-all (this SG)

- moodle-opsworks-webserver
-- http: from 0.0.0.0
-- https: from 0.0.0.0


### Opsworks 

#### Stack
- Stack name : Moodle-ops
- Region: Same as VPC/EFS/RDS
- VPC: Moodle-ops
- Default subnet Moodle Private Subnet
- Default operating system: Amazon Linux [latest]
- Default SSH key: [put in one of your EC2 SSH keys here, or you'll regret it when you go to troubleshoot]
- Chef version: 12
- Use custom Chef cookbooks: yes
- Repo: https://github.com/ITMasters/moodle-on-aws-opsworks.git
- Create a new public/private key rsa pair, add pub key to deploy tab on github add private as Repository SSH Key
- Use OpsWorks security groups: no
- Custom JSON: (example below. s3 backup optional, EFS_ID required)
{
  "S3_backup_bucket": "my-moodledata-bucket",
  "EFS_ID": "fs-1234567a"
}

#### Layer: moodle-web-server

Security:
- moodle-opsworks-all
- moodle-opsworks-webserver

Recipes:
- Setup: apache::default
- Configure: moodle_web_server::configure
- Deploy: moodle_web_server::deploy

Network:
- Elastic load balancer: Moodle
- Public IP Address: Yes

#### Layer: RDS

- Instance/User/Password: [as specified when setting up RDS above]

#### App

You have to add an "App". There's only one: Moodle

Apps->Add App
- Name: Moodle
- Data source type: RDS
-- Database instance/name: as above
- Application Source:
-- Type: S3 Archive
-- URL: full url of zip file that contains moodle + plugins/themes that is hosted on amazon s3 bucket (
-- Access key ID : username of IAM user who has access to above zip file
-- Secret access key: private key for above user


#### Instances

...


### Optional

#### Backup Moodledata to S3:

Backups will be run from the first front-end webserver

To do this, you'll need to 
- create an IAM policy (that gives permission to access an s3 bucket), 
- create IAM role (that gives permission for EC2 instances to use the IAM policy),
- add json to the opsworks stack that includes:
-- the S3 bucket name
-- the S3 bucket region? (not sure if needed)
- add the backup lifecycle event to the moodledata layer
- add the IAM instance profile to moodledata and web layers


## Todo:

high:
- get it more working...

med:
- cloudformation script for all this
- code to check that opsworks moodle 'app' exists
- code to check that mount is still right? depends if remounting is working
-- if File.read(/procsomething).include?(ip:/nfssomething)
- s3 backup/restore
- add detail to the "Backup Moodledata to S3" section of this doc

low:
- moodle_web_server: fix deploy script so that it doesn't need to symlink /var/www/html

## Notes for playing around with Chef local in SSH on individual machines

chef-apply whatever.rb

knife search -c /var/chef/runs/71acfdb8-4900-4ec7-98f2-7f3cc17f4cb2/client.rb node 'role:moodle-web-server'
