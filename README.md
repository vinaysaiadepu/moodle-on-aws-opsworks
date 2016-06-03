# Run Moodle on Amazon AWS Opsworks (Chef 12 Linux)

Attempting to setup Moodle server on Opsworks
- Apache 2.4
- PHP 5.6
- App install from Github

## Setup

### Stack

- Default operating system: Amazon Linux [latest]
- Default SSH key: jhale
- Chef version: 12
- Use custom Chef cookbooks: yes
- Repo: https://github.com/jamesoflol/opsworks-demo.git

### Layer: moodle-web-server

Recipes:
- Configure: moodle_web_server::configure
- Deploy: moodle_web_server::deploy

Network:
- Public IP Address: Yes

Securiy:
- moodle-opsworks-all
- moodle-opsworks-webserver

### Layer: moodle-data-server

Recipes:
- Configure: moodle_data_server

Network:
- Public IP Address: Yes

Securiy:
- moodle-opsworks-all

### Layer: memcached

Recipes:
- Configure: memcached

Network:
- Public IP Address: Yes

Securiy:
- moodle-opsworks-all


## Notes for playing around with Chef local in SSH on individual machines

sudo mkdir /var/chef/cookbooks/test
sudo mkdir /var/chef/cookbooks/test/recipes
sudo echo "" > /var/chef/cookbooks/test/recipes/default.rb
sudo nano /var/chef/cookbooks/test/recipes/default.rb
--put some chef script in now--
sudo chef-client -z -o test
