
require 'chefspec'

describe 'memcached::installer-source' do

  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  before {
    stub_command('which gcc').and_return(false)
    stub_command('yum list installed | grep libevent-devel').and_return(false)
    stub_command('which perl').and_return(false)
  }

  it 'uses default attributes by default' do 
    expect(chef_run.node['memcached']['installer-source']['source-url']).to eq('http://memcached.org/files/memcached-1.4.20.tar.gz')
    expect(chef_run.node['memcached']['installer-source']['download-path']).to eq('/')
    expect(chef_run.node['memcached']['installer-source']['download-filename']).to eq('memcached-1.4.20.tar.gz')
    expect(chef_run.node['memcached']['installer-source']['installation-path']).to eq('/etc/')
    expect(chef_run.node['memcached']['installer-source']['installation-directory']).to eq('memcached')
    expect(chef_run.node['memcached']['installer-source']['prerequisites']['gcc']['install-if-missing']).to eq('yes')
    expect(chef_run.node['memcached']['installer-source']['prerequisites']['libevent']['install-if-missing']).to eq('yes')
    expect(chef_run.node['memcached']['installer-source']['prerequisites']['libevent']['library-path']).to eq('/usr/lib64/libevent.so')
    expect(chef_run.node['memcached']['installer-source']['prerequisites']['libevent']['use-configure-prefix']).to eq('yes')
    expect(chef_run.node['memcached']['installer-source']['configuration']['enable-64bit']).to eq('yes')
    expect(chef_run.node['memcached']['installer-source']['configuration']['enable-threads']).to eq('no')
    expect(chef_run.node['memcached']['installer-source']['clean-up-after-install']).to eq('yes')
  end

  it 'verifies that yum exists as it is required by memcached installation from source process' do 
    expect(chef_run).to run_execute('which yum')
  end

  it 'raises an exception when yum is not found on the system' do 
    expect {
        resource = chef_run.execute('which yum')
        allow(resource).to raise_error
    }.to raise_error
  end

  it 'verifies that grep exists as it is required by memcached installation from source process' do 
    expect(chef_run).to run_execute('which grep')
  end

  it 'raises an exception when grep is not found on the system' do 
    expect {
        resource = chef_run.execute('which grep')
        allow(resource).to raise_error
    }.to raise_error
  end

  it 'verifies that find exists as it is required by memcached installation from source process' do 
    expect(chef_run).to run_execute('which find')
  end

  it 'raises an exception when find is not found on the system' do 
    expect {
      resource = chef_run.execute('which find')
      allow(resource).to raise_error
    }.to raise_error
  end

  it 'verifies that tail exists as it is required by memcached installation from source process' do 
    expect(chef_run).to run_execute('which tail')
  end

  it 'raises an exception when tail is not found on the system' do 
    expect {
      resource = chef_run.execute('which tail')
      allow(resource).to raise_error
    }.to raise_error
  end

  it 'verifies that make exists on the system' do 
    expect(chef_run).to run_execute('which make')
  end

  it 'raises an exception when make does not exists on the system' do 
    expect {
        resource = chef_run.execute('which make')
        allow(resource).to raise_error
    }.to raise_error
  end

  it 'verifies that tar executable exists on the system' do 
    expect(chef_run).to run_execute('which tar')
  end 

  it 'raises an exception if tar executable is not found on the system' do 
    expect { 
        resource = chef_run.execute('which tar')
        allow(resource).to raise_error
    }.to raise_error
  end 

  it 'installs gcc by default if it is not found on the system' do 
    expect(chef_run).to run_execute('yum -y install gcc')
  end

  it 'verifies that gcc exists if gcc installation is set to no and it is not found on the system' do 
    chef_run.node.set['memcached']['installer-source']['prerequisites']['gcc']['install-if-missing'] = 'no'
    chef_run.converge(described_recipe)
    expect(chef_run).to run_execute('which gcc')
  end

  it 'raises an exception if gcc attribute is set to no and it is not found on the system' do 
    chef_run.node.set['memcached']['installer-source']['prerequisites']['gcc']['install-if-missing'] = 'no'
    chef_run.converge(described_recipe)
    expect {
      resource = chef_run.execute('which gcc')
      allow(resource).to raise_error
    }.to raise_error
  end

  it 'installs perl by default if it is not found on the system' do 
    expect(chef_run).to run_execute('yum -y install perl')
  end

  it 'installs libevent by default if it is not found on the system' do 
    expect(chef_run).to run_execute('yum -y install libevent-devel')
  end

  it 'verifies that libevent exists if install-if-missing attribute is set to no' do 
    chef_run.node.set['memcached']['installer-source']['prerequisites']['libevent']['install-if-missing'] = 'no'
    chef_run.converge(described_recipe)
    expect(chef_run).to run_execute('yum list installed | grep libevent-devel')
  end

  it 'raises an exception when libevent is not found on the system and install-if-missing attribute is set to no' do 
    chef_run.node.set['memcached']['installer-source']['prerequisites']['libevent']['install-if-missing'] = 'no'
    chef_run.converge(described_recipe)
    expect {
        resource = chef_run.execute('yum list installed | grep libevent-devel')
        allow(resource).to raise_error
    }.to raise_error
  end

  it 'downloads memcached package' do 
    expect(chef_run).to create_remote_file("#{chef_run.node['memcached']['installer-source']['download-path']}#{chef_run.node['memcached']['installer-source']['download-filename']}")
  end

  it 'download memcached source package using different source url, download path and filename' do 
    chef_run.node.set['memcached']['installer-source']['source-url']        = 'http://different-url.com/latest'
    chef_run.node.set['memcached']['installer-source']['download-path']     = './custom-path/'
    chef_run.node.set['memcached']['installer-source']['download-filename'] = 'memcached-custom-filename.tar.gz'
    chef_run.converge(described_recipe)
    expect(chef_run).to create_remote_file("#{chef_run.node['memcached']['installer-source']['download-path']}#{chef_run.node['memcached']['installer-source']['download-filename']}")
  end

  it 'untars the downloaded package' do 
    download_path = "#{chef_run.node['memcached']['installer-source']['download-path']}#{chef_run.node['memcached']['installer-source']['download-filename']}"
    expect(chef_run).to run_execute("tar -zxvf #{download_path}")
  end

  it 'raises an exception if something goes wrong during untar of the downloaded package' do 
    expect {
        download_path = "#{chef_run.node['memcached']['installer-source']['download-path']}#{chef_run.node['memcached']['installer-source']['download-filename']}"
        resource = chef_run.execute("tar -zxvf #{download_path}")
        allow(resource).to raise_error
    }.to raise_error
  end

  it 'creates installation directory at the specified path' do 
    destination_directory = "#{chef_run.node['memcached']['installer-source']['installation-path']}#{chef_run.node['memcached']['installer-source']['installation-directory']}"
    expect(chef_run).to create_directory("#{destination_directory}")
  end

  it 'configures downloaded package installation path with libevent directory param by default' do 
    libevent_path = "#{chef_run.node['memcached']['installer-source']['prerequisites']['libevent']['library-path']}"
    package_directory = "#{chef_run.node['memcached']['installer-source']['download-path']}#{chef_run.node['memcached']['installer-source']['download-filename'].gsub(/\.tar\.gz$/, '')}"
    destination_directory = "#{chef_run.node['memcached']['installer-source']['installation-path']}#{chef_run.node['memcached']['installer-source']['installation-directory']}"
    expect(chef_run).to run_execute("#{package_directory}/configure --prefix=#{destination_directory} --with-libevent=#{libevent_path} --enable-64bit")
  end

  it 'raises an exception if something goes wrong during installation path configuration with libevent directory param' do 
    expect {
        libevent_path = "#{chef_run.node['memcached']['installer-source']['prerequisites']['libevent']['library-path']}"
        package_directory = "#{chef_run.node['memcached']['installer-source']['download-path']}#{chef_run.node['memcached']['installer-source']['download-filename'].gsub(/\.tar\.gz$/, '')}"
        destination_directory = "#{chef_run.node['memcached']['installer-source']['installation-path']}#{chef_run.node['memcached']['installer-source']['installation-directory']}"
        resource = chef_run.execute("#{package_directory}/configure --prefix=#{destination_directory} --with-libevent=#{libevent_path} --enable-64bit")
        allow(resource).to raise_error
    }.to raise_error
  end

  it 'configures downloaded package without libevent directory path when attribute param is set to no' do 
    chef_run.node.set['memcached']['installer-source']['prerequisites']['libevent']['use-configure-prefix'] = 'no'
    chef_run.converge(described_recipe)
    package_directory = "#{chef_run.node['memcached']['installer-source']['download-path']}#{chef_run.node['memcached']['installer-source']['download-filename'].gsub(/\.tar\.gz$/, '')}"
    destination_directory = "#{chef_run.node['memcached']['installer-source']['installation-path']}#{chef_run.node['memcached']['installer-source']['installation-directory']}"
    expect(chef_run).to run_execute("#{package_directory}/configure --prefix=#{destination_directory} --enable-64bit")
  end

  it 'configures memcached with threads option enabled when set to yes' do 
    chef_run.node.set['memcached']['installer-source']['prerequisites']['libevent']['use-configure-prefix'] = 'no'
    chef_run.node.set['memcached']['installer-source']['configuration']['enable-threads']  = 'yes'
    chef_run.converge(described_recipe)
    package_directory = "#{chef_run.node['memcached']['installer-source']['download-path']}#{chef_run.node['memcached']['installer-source']['download-filename'].gsub(/\.tar\.gz$/, '')}"
    destination_directory = "#{chef_run.node['memcached']['installer-source']['installation-path']}#{chef_run.node['memcached']['installer-source']['installation-directory']}"
    expect(chef_run).to run_execute("#{package_directory}/configure --prefix=#{destination_directory} --enable-64bit --enable-threads")
  end

  it 'runs make commands to test and install downloaded package' do 
    expect(chef_run).to run_execute("make")
  end

  it 'raises an exception if something goes wrong during make' do 
    expect {
        resource = chef_run.execute("make")
        allow(resource).to raise_error
    }.to raise_error
  end

  it 'installs downloaded package via make install' do 
    expect(chef_run).to run_execute("make install")
  end

  it 'raises an exception if something goes wrong during make install' do 
    expect {
        resource = chef_run.execute("make install")
        allow(resource).to raise_error
    }.to raise_error
  end
end