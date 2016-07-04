# Add /srv/opsworks.php file - stores info that Moodle needs to know about other AWS resources

db = search(:aws_opsworks_rds_db_instance, "*:*").first
thisinstance = search(:aws_opsworks_instance, "self:true").first
memcached = search(:aws_opsworks_instance, "role:moodle-web-server AND status:online").first
stack = search(:aws_opsworks_stack).first

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

directory '/mnt/nfs' do
  owner 'apache'
  group 'ec2-user'
  mode '0770'
  action :create
  recursive true
end

mount '/mnt/nfs' do
  device "#{thisinstance['availability_zone']}.#{node['EFS_ID']}.efs.#{stack['region']}.amazonaws.com:/"
  fstype 'nfs4'
  options 'rw','nfsvers=4.1'
  # action [:mount, :enable] # force unmount+remount - needed in case NFS server goes down and changes address
end
