
require 'chefspec'

describe 'memcached::default' do
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  it 'installs memcached' do
    expect(chef_run).to install_package('memcached')
  end
end