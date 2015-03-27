Puppet::Type.type(:foreman_location).provide(:rest) do

  confine :true => begin
    begin
      require 'oauth'
      require 'json'
      require 'puppet_x/theforeman/location'
      require 'puppet_x/theforeman/smartproxy'
      require 'puppet_x/theforeman/compute_resource'
      require 'puppet_x/theforeman/mediatypes'
      require 'puppet_x/theforeman/config_template'
      require 'puppet_x/theforeman/domain'
      require 'puppet_x/theforeman/environment'
      require 'puppet_x/theforeman/subnet'
      true
    rescue LoadError
      false
    end
  end

  mk_resource_methods

  def initialize(value={})
    super(value)
  end

  def self.locations
    PuppetX::TheForeman::Resources::Locations.new(nil)
  end

  def self.smartproxies
    PuppetX::TheForeman::Resources::SmartProxy.new(nil)
  end

  def self.compute_resource
    PuppetX::TheForeman::Resources::ComputeResources.new(nil)
  end

  def self.media
    PuppetX::TheForeman::Resources::MediaTypes.new(nil)
  end

  def self.config_template
    PuppetX::TheForeman::Resources::ConfigTemplates.new(nil)
  end

  def self.domain
    PuppetX::TheForeman::Resources::Domains.new(nil)
  end

  def self.environment
    PuppetX::TheForeman::Resources::Environments.new(nil)
  end

  def self.subnet
    PuppetX::TheForeman::Resources::Subnets.new(nil)
  end

  def self.instances
    location_config = locations.read
    location_config['results'].collect do |s|
      location_hash = {
        :name              => s['name'],
        :id                => s['id'],
        :ensure            => :present,
        :smart_proxies     => s['smart_proxies'],
        :compute_resources => s['compute_resources'],
        :media             => s['media'],
        :config_templates  => s['config_templates'],
        :domains           => s['domains'],
        :subnets           => s['subnets'],
        :environments      => s['environments']
      }
      new(location_hash)
    end
  end

  def self.prefetch(resources)
    locations = instances
    resources.keys.each do |location|
      if provider = locations.find { |l| l.name == location }
        resources[location].provider = provider
      end
    end
  end

  def lookup_ids(crud_class, names)
    resources = crud_class.read
    ids = [""]
    names.each do |name|
      item = resources['results'].find { |s| s['name'] == name }
      ids.push(item['id'].to_s) if item
    end
    return ids
  end
  
  def location_hash(hash)
    location_hash = {
      :location => hash
    }
  end

  def id
    @property_hash[:id]
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    loc_hash = {
      'name'                 => resource[:name],
      'smart_proxy_ids'      => lookup_ids(self.class.smartproxies, resource[:smart_proxies]),
      'compute_resource_ids' => lookup_ids(self.class.compute_resource, resource[:compute_resources]),
      'medium_ids'           => lookup_ids(self.class.media, resource[:media]),
      'config_template_ids'  => lookup_ids(self.class.config_template, resource[:config_templates]),
      'domain_ids'           => lookup_ids(self.class.domain, resource[:domains]),
      'environment_ids'      => lookup_ids(self.class.environment, resource[:environments]),
      'subnet_ids'           => lookup_ids(self.class.subnet, resource[:subnets])
    }
    self.class.locations.create(location_hash(loc_hash))
  end

  def destroy
    self.class.locations.delete(id)
  end

  def smart_proxies=(value)
    self.class.locations.update(id, location_hash(:smart_proxy_ids => lookup_ids(self.class.smartproxies, value)))
  end

  def compute_resources=(value)
    self.class.locations.update(id, location_hash(:compute_resource_ids => lookup_ids(self.class.compute_resource, value)))
  end

  def media=(value)
    self.class.locations.update(id, location_hash(:medium_ids => lookup_ids(self.class.media, value)))
  end

  def config_templates=(value)
    self.class.locations.update(id, location_hash(:config_template_ids => lookup_ids(self.class.config_template, value)))
  end

  def domains=(value)
    self.class.locations.update(id, location_hash(:domain_ids => lookup_ids(self.class.domains, value)))
  end

  def environments=(value)
    self.class.locations.update(id, location_hash(:environment_ids => lookup_ids(self.class.environments, value)))
  end

  def subnets=(value)
    self.class.locations.update(id, location_hash(:subnet_ids => lookup_ids(self.class.subnets, value)))
  end
end
