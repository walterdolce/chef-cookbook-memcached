

remote_file 'download memcached source package file' do 
    source node['memcached']['installer-source']['source-url']
    action :create
    path "#{node['memcached']['installer-source']['download-path']}#{node['memcached']['installer-source']['download-filename']}"
end