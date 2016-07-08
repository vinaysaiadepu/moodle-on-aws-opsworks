# Cloning app from github - this will only grab the first app and ignore all others. This first/only app should be a Moodle github repo
app = search(:aws_opsworks_app).first
app_path = "/srv/#{app['shortname']}"


directory app_path do
	action :create
end

directory app_path + "/*" do
	recursive true
	action :delete
end

#Deploy s3 or git application
case app['app_source']['type']
	when 's3'
		s3_file "/tmp/#{app['shortname']}" + ".zip" do
			bucket_url = app["app_source"]["url"]
			remote_path "/" + bucket_url.split("/", 5)[4]
			bucket "/" + bucket_url.split("/", 5)[3]
			aws_access_key_id app["app_source"]["user"]
			aws_secret_access_key app["app_source"]["password"]
			owner "apache"
			group "ec2-user"
			mode "0770"
			action :create
		end

		execute 'unpack app' do
			command "unzip -o /tmp/#{app['shortname']}" + ".zip -d " + app_path
		end

		file "/tmp/#{app['shortname']}" + ".zip" do
			action :delete
		end
	when 'git'
		
		git app_path do
			repository app["app_source"]["url"]
			revision app["app_source"]["revision"]
			depth 1
		end
end



# Symlink app to /var/www/html
directory '/var/www/html' do
	action :delete
	not_if { File.symlink?('/var/www/html') }
	ignore_failure true
end

link '/var/www/html' do
	to app_path
	not_if { File.symlink?('/var/www/html') }
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
