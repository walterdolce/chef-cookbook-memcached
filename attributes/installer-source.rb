

default['memcached']['installer-source']['source-url']             = 'http://memcached.org/files/memcached-1.4.20.tar.gz'
default['memcached']['installer-source']['download-path']          = '/'
default['memcached']['installer-source']['download-filename']      = 'memcached-1.4.20.tar.gz' # Latest stable release
default['memcached']['installer-source']['installation-path']      = '/etc/'
default['memcached']['installer-source']['installation-directory'] = 'memcached'

default['memcached']['installer-source']['prerequisites']['gcc']['install-if-missing']        = 'yes'
default['memcached']['installer-source']['prerequisites']['perl']['install-if-missing']       = 'yes'
default['memcached']['installer-source']['prerequisites']['libevent']['install-if-missing']   = 'yes'
default['memcached']['installer-source']['prerequisites']['libevent']['use-configure-prefix'] = 'yes'
default['memcached']['installer-source']['prerequisites']['libevent']['library-path']         = '/usr/lib64/libevent.so'

default['memcached']['installer-source']['configuration']['enable-64bit']   = 'yes'
default['memcached']['installer-source']['configuration']['enable-threads'] = 'no'

default['memcached']['installer-source']['clean-up-after-install'] = 'yes'