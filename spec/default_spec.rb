
require 'chefspec'

describe 'memcached::default' do
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }
end