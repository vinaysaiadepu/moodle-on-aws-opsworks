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
	'mysql56',
	'mod24_ssl',
	'mod_proxy'
]

packages.each do |pkg|
	package pkg do
		action :install
	end
end

service 'httpd' do
	action [:enable, :start]
end


directory '/var/www/phpmyadmin' do
  owner 'apache'
  group 'ec2-user'
	mode 00755
	recursive true
	action :create
end

remote_file "/tmp/phpMyAdmin-4.6.4-all-languages.tar.gz" do
  owner user
  group group
  mode 00644
	retries 5
	retry_delay 2
  action :create
  source "https://files.phpmyadmin.net/phpMyAdmin/4.6.4/phpMyAdmin-4.6.4-all-languages.tar.gz"
  not_if { ::File.exists?("/tmp/phpMyAdmin-4.6.4-all-languages.tar.gz")}
end

bash 'extract-php-myadmin' do
	user user
	group group
	cwd '/var/www/phpmyadmin/'
	code <<-EOH
		rm -fr *
		tar xzf /tmp/phpMyAdmin-4.6.4-all-languages.tar.gz
		mv phpMyAdmin-4.6.4-all-languages/* /var/www/phpmyadmin/
		rm -fr phpMyAdmin-4.6.4-all-languages
	EOH
	not_if { ::File.exists?("/var/www/phpmyadmin/phpMyAdmin-4.6.4-all-languages")}
end


