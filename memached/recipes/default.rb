# Installs/runs memcached

package 'memached' do
	action :install
end

service 'memcached' do
	action :start
end
