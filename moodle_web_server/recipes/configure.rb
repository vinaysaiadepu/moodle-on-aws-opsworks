# Add /srv/opsworks.php file - stores info that Moodle needs to know about other AWS resources

db = search(:aws_opsworks_rds_db_instance, "*:*").first
memcached = search(:aws_opsworks_instance, "role:memcached AND status:online").first

template 'opsworks.php' do
	path "/srv/opsworks.php"
	source "opsworks.php.erb"
	owner "root"
	group "root"
	mode 775
	variables(
		:db_host		=> db["address"],
		:db_name		=> db["db_instance_identifier"],
		:db_user		=> db["db_user"],
		:db_pass		=> db["db_password"],
		:memcached_ip	=> memcached["private_ip"]
	)
end


# Mount Moodledata NFS store

# directory "/mnt/nfs" do
#   owner 'root'
#   group 'root'
#   mode '0755'
#   action :create
# end

directory "/mnt/nfs/moodledata" do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
  recursive true
end

moodledata = search(:aws_opsworks_instance, "role:moodle-data-server AND status:online").first

mount "/mnt/nfs/moodledata" do
  device moodledata["private_ip"] + ":/vol/moodledata"
  fstype "nfs"
  options "rw"
  # action [:mount, :enable] # uncommenting this will force unmount+remount
end
