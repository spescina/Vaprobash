VAGRANTFILE_API_VERSION = "2"

path = "#{File.dirname(__FILE__)}"

require 'yaml'
require path + '/scripts/classy.rb'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  Classy.configure(config, YAML::load(File.read(path + '/Classy.yaml')))
end