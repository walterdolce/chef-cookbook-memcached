
execute 'check yum executable existence for later prerequisites checks' do 
    command 'which yum'
end

execute 'check grep executable existence for later prerequisites checks' do 
    command 'which grep'
end

execute 'check libevent existence on the system' do 
    command 'yum list installed | grep libevent'
end

execute 'check tar executable existence to untar downloaded package' do 
    command 'which tar'
end

execute 'check make executable existence to install downloaded package' do 
    command 'which make'
end

remote_file 'download memcached package file' do 
    source node['memcached']['installer-source']['source-url']
    action :create
    path "#{node['memcached']['installer-source']['download-path']}#{node['memcached']['installer-source']['download-filename']}"
end

execute 'untar downloaded package' do 
    command "tar -zxvf #{node['memcached']['installer-source']['download-path']}#{node['memcached']['installer-source']['download-filename']}"
end

execute 'configure installation path for downloaded package' do 
    command "./configure --prefix=#{node['memcached']['installer-source']['installation-path']}memcached"
end

execute 'run make && make test before real installation' do 
    command 'make && make test'
end

execute 'run make install to install downloaded packege' do 
    command 'make install'
end