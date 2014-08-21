

remote_file 'memcached source package file' do 
    source 'http://memcached.org/latest'
    action :create
    path 'memcached.tar.gz'
end