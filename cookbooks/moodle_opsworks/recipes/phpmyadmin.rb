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
