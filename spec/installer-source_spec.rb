
require 'chefspec'

describe 'memcached::installer-source' do

  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  it 'downloads memcached source' do 
    expect(chef_run).to create_remote_file('memcached.tar.gz')
  end

end