# Run Moodle on Amazon AWS Opsworks (Chef 12 Linux)

Attempting to setup Moodle server on Opsworks
- Apache 2.4
- PHP 5.6
- App install from Github

## Setup

### Pre-req

#### EC2 Security Groups: 

- moodle-opsworks-all
-- ssh from your IP
- moodle-opsworks-webserver
-- http/https from 0.0.0.0

#### RDS

Set up a t2.micro or small RDS instance.
- MySQL 5.7
- VPC: Same as all others in this setup
- Security group: defaults + moodle-opsworks-all
- Parameter groups -> new -> name = "moodle" -> log_bin_trust_function_creators => 1

### Opsworks 

#### Stack

- Default operating system: Amazon Linux [latest]
- Default SSH key: [put in one of your EC2 SSH keys here, or you'll regret it when you go to troubleshoot]
- Chef version: 12
- Use custom Chef cookbooks: yes
- Repo: https://github.com/jamesoflol/opsworks-demo.git
- Use OpsWorks security groups: no

#### Layer: moodle-web-server

Recipes:
- Configure: moodle_web_server::configure
- Deploy: moodle_web_server::deploy

Network:
- Public IP Address: Yes

Securiy:
- moodle-opsworks-all
- moodle-opsworks-webserver

#### Layer: moodle-data-server

Recipes:
- Configure: moodle_data_server

Network:
- Public IP Address: Yes

Securiy:
- moodle-opsworks-all

#### Layer: memcached

Recipes:
- Configure: memcached

Network:
- Public IP Address: Yes

Securiy:
- moodle-opsworks-all


## Todo:

high:
- elb
- get it more working...

med:
- s3 backup/restore
- cloudformation script for all this

low:
- moodle_web_server: fix deploy script so that it doesn't need to symlink /var/www/html

## Notes for playing around with Chef local in SSH on individual machines

sudo mkdir /var/chef/cookbooks/test
sudo mkdir /var/chef/cookbooks/test/recipes
sudo echo "" > /var/chef/cookbooks/test/recipes/default.rb
sudo nano /var/chef/cookbooks/test/recipes/default.rb
--put some chef script in now--
sudo chef-client -z -o test
