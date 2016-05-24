include_recipe 'apache'

# Cloning app from github - this will only grab the first app and ignore all others.
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
end
link '/var/www/html' do
	to app_path
end

# Add Moodle config.php file
template 'config.php' do
	path "#{app_path}/config.php"
	source "config.php.erb"
	owner "root"
	group "root"
	mode 775
end