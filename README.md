# Run Moodle on Amazon AWS Opsworks (Chef 12 Linux)

Attempting to setup Moodle server on Opsworks
- Apache 2.4
- PHP 5.6
- Memcached (runs on 1st front-end web server)
- Amazon RDS (MySQL 5.7)
- App install from Github

This requires Amazon EFS (Elastic File System), which is currently only in 3 AWS regions.


## Setup
[Instructions in Wiki](https://github.com/ITMasters/moodle-on-aws-opsworks/wiki/Setup)

## Todo:
high:
- code to check that mount is still right? depends if remounting is working [if File.read(/procsomething).include?(ip:/nfssomething)]
- improve muc cache recipe so it can be included in run list at setup

med:
- test kitchen tests
- code to check that opsworks moodle 'app' exists
- s3 backup/restore
- add detail to the "Backup Moodledata to S3" section of this doc
- add instructions for bundling thmes/plugins

low:
- moodle_web_server: fix deploy script so that it doesn't need to symlink /var/www/html
- cloudformation script for all this
- Allow app install from sources other than s3/git

## Notes for playing around with Chef local in SSH on individual machines

chef-apply whatever.rb

knife search -c /var/chef/runs/71acfdb8-4900-4ec7-98f2-7f3cc17f4cb2/client.rb node 'role:moodle-web-server'
