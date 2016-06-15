# Add /srv/opsworks.php file - stores info that Moodle needs to know about other AWS resources

db = search(:aws_opsworks_rds_db_instance, "*:*").first
memcached = search(:aws_opsworks_instance, "role:memcached AND status:online").first

template 'opsworks.php' do
	path '/srv/opsworks.php'
	source 'opsworks.php.erb'
	owner 'apache'
	group 'ec2-user'
	mode '0770'
	variables(
		:db_host		=> db['address'],
		:db_user		=> db['db_user'],
		:db_pass		=> db['db_password'],
		:memcached_ip	=> memcached['private_ip']
	)
end


# Create and mount Moodledata NFS folder

directory '/mnt/nfs/moodledata' do
  owner 'apache'
  group 'ec2-user'
  mode '0770'
  action :create
  recursive true
end

moodledata = search(:aws_opsworks_instance, "role:moodle-data-server AND status:online").first

mount '/mnt/nfs/moodledata' do
  device moodledata['private_ip'] + ':/vol/moodledata'
  fstype 'nfs'
  options 'rw'
  action [:mount, :enable] # force unmount+remount - needed in case moodledata server goes down and is recreated
end
