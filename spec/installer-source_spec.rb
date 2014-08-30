
require 'chefspec'

describe 'memcached::installer-source' do

  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  it 'uses default attributes by default' do 
    expect(chef_run.node['memcached']['installer-source']['source-url']).to        eq('http://memcached.org/files/memcached-1.4.20.tar.gz')
    expect(chef_run.node['memcached']['installer-source']['download-path']).to     eq('./')
    expect(chef_run.node['memcached']['installer-source']['download-filename']).to eq('memcached-1.4.20.tar.gz')
    expect(chef_run.node['memcached']['installer-source']['installation-path']).to eq('/etc/')
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

  it 'looks for yum as it is required for prerequisites checks' do 
    expect(chef_run).to run_execute('which yum')
  end

  it 'raises exception when yum is not found on the system' do 
    expect {
        resource = chef_run.execute('which yum')
        allow(resource).to raise_error
    }.to raise_error
  end

  it 'looks for grep executable as it is required for prerequisites checks' do 
    expect(chef_run).to run_execute('which grep')
  end

  it 'raises an exception when grep is not found on the system' do 
    expect {
        resource = chef_run.execute('which grep')
        allow(resource).to raise_error
    }.to raise_error
  end

  it 'checks for libevent existence' do 
    expect(chef_run).to run_execute('yum list installed | grep libevent')
  end

  it 'raises an exception when libevent is not found on the system' do 
    expect {
        resource = chef_run.execute('yum list installed | grep libevent')
        allow(resource).to raise_error
    }.to raise_error
  end

  it 'checks for make executable' do 
    expect(chef_run).to run_execute('which make')
  end

  it 'raises an exception when make executable is not found on the system' do 
    expect {
        resource = chef_run.execute('which make')
        allow(resource).to raise_error
    }.to raise_error
  end

  it 'looks for tar executable to untar the downloaded package' do 
    expect(chef_run).to run_execute('which tar')
  end 

  it 'throws exception if cannot find tar executable' do 
    expect { 
        resource = chef_run.execute('which tar')
        allow(resource).to raise_error
    }.to raise_error
  end 

  it 'untars the downloaded package' do 
    expect(chef_run).to run_execute("tar -zxvf #{chef_run.node['memcached']['installer-source']['download-path']}#{chef_run.node['memcached']['installer-source']['download-filename']}")
  end

  it 'throws exception if something goes wrong when untar downloaded package' do 
    expect {
        resource = chef_run.execute("tar -zxvf #{chef_run.node['memcached']['installer-source']['download-path']}#{chef_run.node['memcached']['installer-source']['download-filename']}")
        allow(resource).to raise_error
    }.to raise_error
  end

  it 'configures downloaded package installation path' do 
    expect(chef_run).to run_execute("./configure --prefix=#{chef_run.node['memcached']['installer-source']['installation-path']}memcached")
  end

  it 'raises an exception if something goes wrong during installation path configuration' do 
    expect {
        resource = chef_run.execute("./configure --prefix=#{chef_run.node['memcached']['installer-source']['installation-path']}memcached")
    }
  end

  it 'runs make commands to test and install downloaded package' do 
    expect(chef_run).to run_execute('make && make test')
  end

  it 'raises an exception if something goes wrong during make && make test' do 
    expect {
        resource = chef_run.execute('make && make test')
        allow(resource).to raise_error
    }.to raise_error
  end

  it 'installs downloaded package via make install' do 
    expect(chef_run).to run_execute('make install')
  end

  it 'raises an exception if something goes wrong during make install' do 
    expect {
        resource = chef_run.execute('make install')
        allow(resource).to raise_error
    }.to raise_error
  end
end