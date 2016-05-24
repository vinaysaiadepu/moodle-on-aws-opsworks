Attempting to setup Moodle server on Opsworks
- Apache 2.4
- PHP 5.6
- App install from Github

For now, this script only allows one Opsworks "app" per EC2 instance. (The app is Moodle.) Others will be ignored. This should suit our purposes fine.


Notes for playing around with Chef local

sudo mkdir /var/chef/cookbooks/test
sudo mkdir /var/chef/cookbooks/test/recipes
sudo echo "" > /var/chef/cookbooks/test/recipes/default.rb
sudo nano /var/chef/cookbooks/test/recipes/default.rb
# put some chef script in now

sudo chef-client -z -o test
