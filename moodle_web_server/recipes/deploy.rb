app = search(:aws_opsworks_app).first
app_path = "/srv/#{app['shortname']}"
git app_path do
	repository app["app_source"]["url"]
	revision app["app_source"]["revision"]
	depth 1
end

# Symlink app to /var/www/html
directory '/var/www/html' do
	action :delete
	ignore_failure true
end
link '/var/www/html' do
	to app_path
end

# Add Moodle config.php file
template 'config.php' do
	path "#{app_path}/config.php"
	source "config.php.erb"
	owner "apache"
	group "ec2-user"
	mode '0770'
	variables(
		:db_name => app["data_sources"][0]["database_name"]
	)
end

# Add PHP file for load balancer check
template 'aws-up-check.php' do
	path "#{app_path}/aws-up-check.php"
	source "aws-up-check.php.erb"
	owner "apache"
	group "ec2-user"
	mode '0770'
end
