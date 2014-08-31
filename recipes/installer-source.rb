downloaded_file_path         = "#{node['memcached']['installer-source']['download-path']}#{node['memcached']['installer-source']['download-filename']}"
downloaded_file_path_cleaned = "#{downloaded_file_path.gsub(/\.tar\.gz$/, '')}"
package_installation_dir     = "#{node['memcached']['installer-source']['installation-path']}#{node['memcached']['installer-source']['installation-directory']}"

execute 'verify yum executable existence for later prerequisites checks' do 
    command 'which yum'
end

execute 'verify grep executable existence for later prerequisites checks' do 
    command 'which grep'
end

execute 'verify that find executable exists as required by memcached::installer-source recipe' do 
    command 'which find'
end

execute 'verify that tail executable exists' do 
    command 'which tail'
end

execute 'verify make executable existence to install downloaded package' do 
    command 'which make'
end

execute 'verify tar executable existence to untar downloaded package' do 
    command 'which tar'
end

if node['memcached']['installer-source']['prerequisites']['gcc']['install-if-missing'] == 'yes'
    execute 'install gcc in order to build downloaded package from source' do 
        command 'yum -y install gcc'
        user 'root'
        not_if 'which gcc'
    end
else
    execute 'verify gcc existence to build downloaded package from source' do 
        command 'which gcc'
    end
end

if node['memcached']['installer-source']['prerequisites']['perl']['install-if-missing'] == 'yes' 
    execute 'install perl as required by memcached' do 
        command 'yum -y install perl'
        user 'root'
        not_if 'which perl'
    end
else 
    execute 'verify perl existence on the system' do 
        command 'which perl'
    end
end

if node['memcached']['installer-source']['prerequisites']['libevent']['install-if-missing'] == 'yes' 
    execute 'install libevent as required by memcached' do 
        command 'yum -y install libevent-devel'
        user 'root'
        not_if 'yum list installed | grep libevent-devel'
    end
else 
    execute 'verify libevent existence on the system' do 
        command 'yum list installed | grep libevent-devel'
        user 'root'
    end
end

remote_file 'download memcached package file' do 
    source node['memcached']['installer-source']['source-url']
    action :create
    path downloaded_file_path
end

execute 'untar downloaded package' do 
    command "tar -zxvf #{downloaded_file_path}"
end

directory package_installation_dir do
  owner "root"
  group "root"
  mode 00755
  action :create
end

enable_64bit = ''
if node['memcached']['installer-source']['configuration']['enable-64bit'] == 'yes' 
    enable_64bit = ' --enable-64bit'
end
enable_threads = ''
if node['memcached']['installer-source']['configuration']['enable-threads'] == 'yes' 
    enable_threads = ' --enable-threads'
end

if node['memcached']['installer-source']['prerequisites']['libevent']['use-configure-prefix'] == 'yes'
    libevent_path = "#{node['memcached']['installer-source']['prerequisites']['libevent']['library-path']}"
    configure_command = "#{downloaded_file_path_cleaned}/configure --prefix=#{package_installation_dir} --with-libevent=#{libevent_path}#{enable_64bit}#{enable_threads}"
else 
    configure_command = "#{downloaded_file_path_cleaned}/configure --prefix=#{package_installation_dir}#{enable_64bit}#{enable_threads}"
end

execute 'configure installation path for downloaded package' do 
    command configure_command
    cwd downloaded_file_path_cleaned
    user 'root'
end

execute 'run make before real installation' do 
    command "make"
    cwd downloaded_file_path_cleaned
    user 'root'
end

execute 'run make install to install downloaded packege' do 
    command "make install"
    cwd downloaded_file_path_cleaned
    user 'root'
end