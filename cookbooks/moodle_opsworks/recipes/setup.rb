# install apache and modules needed for moodle
packages = [
	'httpd24',
	'php56',
	'php56-opcache',
	'php56-mysqlnd',
	'php56-xmlrpc',
	'php56-intl',
	'php56-soap',
	'php56-gd',
	'php56-mbstring',
	'php56-pecl-memcached',
	'mysql56'
]

packages.each do |pkg|
	package pkg do
		action :install
	end
end

service 'httpd' do
	action [:enable, :start]
end

memcached_instance 'memcached_sessions' do
  port 11_212
  memory 64
  action [:start, :enable]
end

## Seperate cache so we can purge without killing session
memcached_instance 'memcached_application' do
  port 111_212
  memory 128
  action [:start, :enable]
end


