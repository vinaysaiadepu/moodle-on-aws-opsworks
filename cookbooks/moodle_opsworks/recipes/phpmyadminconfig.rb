if Chef::Config[:solo]
  Chef::Log.warn('This recipe uses search. Chef Solo does not support search.')
else

db = search(:aws_opsworks_rds_db_instance, '*:*').first

# Create and mount Moodledata NFS folder
directory '/mnt/nfs' do
  owner 'apache'
  group 'ec2-user'
  mode '0770'
  action :create
  recursive true
end

include_recipe "#{cookbook_name}::moodledata"

template "/var/www/phpmyadmin/config.inc.php" do
	source 'config.inc.php.erb'
	owner user
	group group
	mode 00644
  variables(
      db_host: db['address'],
      blowfish_secret: Digest::SHA1.hexdigest(IO.read('/dev/urandom', 2048))
  )
end


    directory '/var/www/html' do
      action :delete
      not_if { File.symlink?('/var/www/html') }
      ignore_failure true
    end

    link '/var/www/html' do
      to '/var/www/phpmyadmin/'
    end


end
