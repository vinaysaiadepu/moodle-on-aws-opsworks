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

service "httpd" do
	action [:enable, :start]
end



# directory "/etc/httpd/sites-available" do
# 	mode '0755'
# 	owner 'root'
# 	group 'root'
# 	action :create
# end

# directory "/etc/httpd/sites-enabled" do
# 	mode '0755'
# 	owner 'root'
# 	group 'root'
# 	action :create
# end
