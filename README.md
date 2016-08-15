# Run Moodle on Amazon AWS Opsworks (Chef 12 Linux)

Attempting to setup Moodle server on Opsworks
- Apache 2.4
- PHP 5.6
- Memcached (runs on 1st front-end web server)
- Amazon RDS (MySQL 5.7)
- App install from Github

This requires Amazon EFS (Elastic File System), which is currently only in 3 AWS regions.

## Build/Package:
run "berks package" from the cookbooks/moodle_opsworks directory

note: requires berkshelf to be installed, install with the [Chef DK](https://downloads.chef.io/chef-dk/)
## Setup:
[Instructions in Wiki](https://github.com/ITMasters/moodle-on-aws-opsworks/wiki/Setup)

## Todo:
high:
- code to check that mount is still right? depends if remounting is working [if File.read(/procsomething).include?(ip:/nfssomething)]

med:
- test kitchen tests
- add detail to the "Backup Moodledata to S3" section of this doc

low:
- moodle_web_server: fix deploy script so that it doesn't need to symlink /var/www/html
- cloudformation script for all this (or setup scripts)
- aws s3 cp end file after the aws s3 sync

## Notes for playing around with Chef local in SSH on individual machines

chef-apply whatever.rb

Find Attributes:
knife search -c "$(\ls -1dt /var/chef/runs/*/ | head -n 1)client.rb" node 'role:<short name of layer>'

Run a lifecycle event:
sudo opsworks-agent-cli run_command configure "$(\ls -1dt /var/chef/runs/*/ | head -n 1)attribs.json"


