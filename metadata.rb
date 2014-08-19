##
# Memcached software cookbook
#
# Author:: Walter Dolce <walterdolce@gmail.com>
#
##
name             'memcached'
version          '0.1.0'
attribute        'memcached',
                    :display_name => 'Memcached',
                    :description  => 'Memcached installation and configuration cookbook'
maintainer       'Walter Dolce'
maintainer_email 'walterdolce@gmail.com'
description      'Memcached installation and configuration cookbook'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
license          'MIT'