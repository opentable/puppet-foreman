Puppet::Type.type(:foreman_architecture).provide(:rest) do

  confine :true => begin
    begin
      require 'oauth'
      require 'json'
      require 'puppet_x/theforeman/architecture'
      true
    rescue LoadError
      false
    end
  end

  mk_resource_methods

  def initialize(value={})
    super(value)
  end

  def self.architectures
    PuppetX::TheForeman::Resources::Architectures.new(nil)
  end

  def self.instances
    arch_config = architectures.read
    arch_config['results'].collect do |s|
      arch_hash = {
        :name   => s['name'],
        :id     => s['id'],
        :ensure => :present
      }
      new(arch_hash)
    end
  end

  def self.prefetch(resources)
    architectures = instances
    resources.keys.each do |architecture|
      if provider = architectures.find { |a| a.name == architecture }
        resources[architecture].provider = provider
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    arch_hash = {
      'name' => resource[:name]
    }

    self.class.architectures.create(arch_hash)
  end

  def destroy
    self.class.architectures.delete(id)
  end

  def name=(value)
    self.class.architectures.update(id, { :name => value })
  end
  
  def id
    @property_hash[:id]
  end
end
