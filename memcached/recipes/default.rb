# Installs/runs memcached

package 'memcached' do
	action :install
end

service 'memcached' do
	action :enable
end
