packages = [
	'httpd24',
	'php56'
]

packages.each do |pkg|
	package pkg do
		action :install
	end
end

service "httpd" do
	action :start
end

# directory "/etc/httpd/sites-available" do
# 	mode 0755
# 	owner 'root'
# 	group 'root'
# 	action :create
# end

# directory "/etc/httpd/sites-enabled" do
# 	mode 0755
# 	owner 'root'
# 	group 'root'
# 	action :create
# end