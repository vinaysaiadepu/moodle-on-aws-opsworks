db = search(:aws_opsworks_rds_db_instance, "*:*").first


docker_service 'default' do
  action [:create, :start]
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

include_recipe 'oh-my-zsh'