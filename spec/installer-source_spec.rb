
require 'chefspec'

describe 'memcached::installer-source' do

  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  it 'uses default attributes by default' do 
    expect(chef_run.node['memcached']['installer-source']['source-url']).to        eq('http://memcached.org/files/memcached-1.4.20.tar.gz')
    expect(chef_run.node['memcached']['installer-source']['download-path']).to     eq('./')
    expect(chef_run.node['memcached']['installer-source']['download-filename']).to eq('memcached-1.4.20.tar.gz')
  end

  it 'downloads memcached source package' do 
    expect(chef_run).to create_remote_file("#{chef_run.node['memcached']['installer-source']['download-path']}#{chef_run.node['memcached']['installer-source']['download-filename']}")
  end

  it 'download memcached source package using different source url, download path and filename' do 
    chef_run.node.set['memcached']['installer-source']['source-url']        = 'http://different-url.com/latest'
    chef_run.node.set['memcached']['installer-source']['download-path']     = './custom-path/'
    chef_run.node.set['memcached']['installer-source']['download-filename'] = 'memcached-custom-filename.tar.gz'
    chef_run.converge(described_recipe)
    expect(chef_run).to create_remote_file("#{chef_run.node['memcached']['installer-source']['download-path']}#{chef_run.node['memcached']['installer-source']['download-filename']}")
  end

end