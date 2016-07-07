# Cloning app from github - this will only grab the first app and ignore all others. This first/only app should be a Moodle github repo
include_recipe "s3_file"
app = search(:aws_opsworks_app).first
app_path = "/srv/#{app['shortname']}"
bucket_url = app["app_source"]["url"]


s3_file "/tmp/itmmoodle.zip" do
    remote_path "/" + url.split("/", 5)[5]
    bucket "/" + url.split("/", 5)[4]
    aws_access_key_id app["app_source"]["user"]
    aws_secret_access_key app["app_source"]["password"]
    s3_url "https://s3.amazonaws.com/bucket"
    owner "apache"
    group "ec2-user"
    mode "0770"
    action :create
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
