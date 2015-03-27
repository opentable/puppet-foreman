Puppet::Type.type(:foreman_environment).provide(:rest) do
  
  confine :true => begin
    begin
      require 'oauth'
      require 'json'
      require 'puppet_x/theforeman/environment'
      true
    rescue LoadError
      false
    end
  end

  mk_resource_methods

  def initialize(value={})
    super(value)
  end

  def self.environments
    PuppetX::TheForeman::Resources::Environments.new(nil)
  end

  def self.instances
    environment_config = environments.read
    environment_config['results'].collect do |s|
      env_hash = {
        :name   => s['name'],
        :id     => s['id'],
        :ensure => :present
      }
      new(env_hash)
    end
  end

  def self.prefetch(resources)
    environments = instances
    resources.keys.each do |environment|
      if provider = environments.find { |e| e.name == environment }
        resources[environment].provider = provider
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    env_hash = {
      'name' => resource[:name]
    }

    self.class.environments.create(env_hash)
  end

  def destroy
    self.class.environments.delete(id)
  end

  def id
    @property_hash[:id]
  end

  def name=(value)
    self.class.environments.update(id, { :name => value })
  end

end
