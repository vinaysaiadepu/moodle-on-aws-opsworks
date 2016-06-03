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