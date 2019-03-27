Puppet::Type.type(:foreman_compute_profile).provide(:rest) do

  confine :true => begin
    begin
      require 'oauth'
      require 'json'
      require 'puppet_x/theforeman/compute_profile'
      require 'puppet_x/theforeman/compute_resource'
      require 'puppet_x/theforeman/compute_attributes'
      true
    rescue LoadError
      false
    end
  end

  mk_resource_methods

  def initialize(value={})
    super(value)
  end

  def self.compute_profiles
    PuppetX::TheForeman::Resources::ComputeProfiles.new(nil)
  end

  def self.compute_resources
    PuppetX::TheForeman::Resources::ComputeResources.new(nil)
  end

  def self.compute_attributes
    PuppetX::TheForeman::Resources::ComputeAttributes.new(nil)
  end

  def self.instances
    profile_config = compute_profiles.read
    profile_config['results'].collect do |s|
      profile_hash = {
        :name   => s['name'],
        :id     => s['id'],
        :ensure => :present,
        :compute_attributes => s['compute_attributes']
      }
      new(profile_hash)
    end
  end

  def self.prefetch(resources)
    compute_profiles = instances
    resources.keys.each do |profile|
      if provider = compute_profiles.find { |p| p.name == profile }
        resources[profile].provider = provider
      end
    end
  end
  
  def compute_resource(name)
    resource = self.class.compute_resources.read
    resource['results'].find { |s| s['name'] == name }
  end

  def compute_profile(name)
    resource = self.class.compute_profiles.read
    resource['results'].find { |s| s['name'] == name }
  end

  def id
    @property_hash[:id]
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    profile_hash = {
      'name' => resource[:name]
    }

    self.class.compute_profiles.create(profile_hash)

    profile = compute_profile(resource[:name])
    profile_id = profile ? profile['id'] : nil

    resource[:compute_attributes].each do |name,value|
      comp_resource = compute_resource(name)
      attributes_hash = {
        'compute_attribute' => {
          'compute_profile_id' => profile_id,
          'compute_resource_id' => comp_resource['id'],
          'vm_attrs' => value
        },
        'compute_resource_id' => comp_resource['id']
      }
    
      self.class.compute_attributes.create(profile_id, comp_resource['id'], attributes_hash)
    end

  end

  def destroy
    self.class.compute_profiles.delete(id)
  end

  def name=(value)
    self.class.compute_profiles.update(id, {:name => value})
  end

  def compute_attributes=(value)
    self.class.compute_profiles.update(id, {:compute_attributes => value})
  end
end
