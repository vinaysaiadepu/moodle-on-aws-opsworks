thisinstance = search(:aws_opsworks_instance, 'self:true').first
firstinstance = search(:aws_opsworks_instance, 'role:moodle-web-server AND status:online').first
# TODO check for existance of the moodle data folder and muc cache folder so this can be included  in configure 


# Only first instance works as a memcached host
if thisinstance['instanceid'] == firstinstance['instanceid']

  template 'config.php' do
    path '/mnt/nfs/moodledata/muc/config.php'
    source 'config.php.muc.erb'
    owner 'apache'
    group 'ec2-user'
    mode '0770'
    variables(
        :memcached_ip => firstinstance['private_ip']
    )
  end


  # setup moodle cache to use memcahced
  template '/var/www/html/admin/cli/scan_cache.php' do
    source 'scan_cache.php'
  end

  # scan cache afterwards to pickup any changes
  execute 'apache_configtest' do
    command 'sudo -u apache /usr/bin/php /var/www/html/admin/cli/scan_cache.php'
  end
else

end






