packages = [
	'httpd24',
	'php56'
]

packages.each do |pkg|
	package pkg do
		action :install
	end
end