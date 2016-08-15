if Chef::Config[:solo]
  Chef::Log.warn('This recipe uses search. Chef Solo does not support search.')
else

db = search(:aws_opsworks_rds_db_instance, '*:*').first


## TODO, check if db details have changed, most of the time they won't and we can probably ignore removing/recreating the instance

# Create and mount Moodledata NFS folder
directory '/mnt/nfs' do
  owner 'apache'
  group 'ec2-user'
  mode '0770'
  action :create
  recursive true
end

include_recipe "#{cookbook_name}::moodledata"

execute 'stop all docker containers' do
  command 'docker stop $(docker ps -a -q)'
end

execute 'remove all docker containers' do
  command 'docker rm $(docker ps -a -q)'
end

# Pull latest image
docker_image 'phpmyadmin/phpmyadmin' do
  tag 'latest'
  action :pull
end

# Run container exposing ports
docker_container 'my_myadmin' do
  repo 'phpmyadmin/phpmyadmin'
  tag 'latest'
  port '80:80'
  env "PMA_HOST=#{db['address']}"
end

end
