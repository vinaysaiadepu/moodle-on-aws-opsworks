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

include_recipe 's3_file'
include_recipe "#{cookbook_name}::moodledata"

# use our public and private keys from S3
s3_file "/etc/pki/tls/certs/server.crt" do
  bucket "itm-moodle"
  remote_path "myadmin.crt"
  mode '0400'
  owner 'root'
  group 'root'
  aws_access_key_id node[:custom_access_key]
  aws_secret_access_key node[:custom_secret_key]
end

s3_file "/etc/pki/tls/certs/server.key" do
  bucket "itm-moodle"
  remote_path "myadmin.key"
  mode '0400'
  owner 'root'
  group 'root'
  aws_access_key_id node[:custom_access_key]
  aws_secret_access_key node[:custom_secret_key]
end

template 'ssl.conf' do
  path '/etc/httpd/conf.d/ssl.conf'
  source 'ssl.conf'
  owner 'root'
  group 'root'
  mode '0644'
end

template 'httpd.conf' do
  path '/etc/httpd/conf/httpd.conf'
  source 'httpd.conf'
  owner 'root'
  group 'root'
  mode '0644'
end

template '.htaccess' do
  path '/var/www/html/.htaccess'
  source '.htaccess'
  owner 'root'
  group 'root'
  mode '0644'
end

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
