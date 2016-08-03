db = search(:aws_opsworks_rds_db_instance, "*:*").first

packages = [
	'mysql56'
]

packages.each do |pkg|
	package pkg do
		action :install
	end
end

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