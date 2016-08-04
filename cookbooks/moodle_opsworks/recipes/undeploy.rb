if Chef::Config[:solo]
  Chef::Log.warn('This recipe uses search. Chef Solo does not support search.')
else

# Undo the deploy events
app = search(:aws_opsworks_app).first
app_path = "/srv/#{app['shortname']}"

directory app_path do
  recursive true
  action :delete
end

# Symlink app to /var/www/html
directory '/var/www/html' do
  action :delete
  ignore_failure true
end

link '/var/www/html' do
  to app_path
end

file "/tmp/#{app['shortname']}" + '.zip' do
  action :delete
end

end
