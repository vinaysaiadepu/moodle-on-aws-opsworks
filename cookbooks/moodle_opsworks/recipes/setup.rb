include_recipe 'moodle_opsworks::apache'

memcached_instance 'memcached_sessions' do
  port 11_212
  memory 64
  action :start
end
## Seperate cache so we can purge without killing session
memcached_instance 'memcached_application' do
  port 111_212
  memory 128
  action :start
end
