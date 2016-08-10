name 'moodle_opsworks'
maintainer 'The Authors'
maintainer_email 'techsupport@itmasters.edu.au'
description 'Installs/Configures moodle_opsworks'
long_description 'Installs/Configures moodle_opsworks'
version '0.1.0'

issues_url 'https://github.com/ITMasters/moodle-on-aws-opsworks/issues' if respond_to?(:issues_url)
source_url 'https://github.com/ITMasters/moodle-on-aws-opsworks' if respond_to?(:source_url)

depends 'memcached'
depends 'docker'
depends 's3_file'
depends 'oh_my_zsh'
depends 'xdebug'
depends 'cloudwatch-logs'