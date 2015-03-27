Puppet::Type.type(:foreman_organization).provide(:rest) do

  confine :true => begin
    begin
      require 'oauth'
      require 'json'
      require 'puppet_x/theforeman/organization'
      require 'puppet_x/theforeman/smartproxy'
      require 'puppet_x/theforeman/compute_resource'
      require 'puppet_x/theforeman/mediatypes'
      require 'puppet_x/theforeman/config_template'
      require 'puppet_x/theforeman/domain'
      require 'puppet_x/theforeman/environment'
      require 'puppet_x/theforeman/subnet'
      require 'puppet_x/theforeman/location'
      true
    rescue LoadError
      false
    end
  end
 
  mk_resource_methods

  def initialize(value={})
    super(value)
  end

  def self.organizations
    PuppetX::TheForeman::Resources::Organizations.new(nil)
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

  def self.location
    PuppetX::TheForeman::Resources::Locations.new(nil)
  end
   
  def self.instances
    org_config = organizations.read
    org_config['results'].collect do |s|
      org_hash = {
        :name              => s['name'],
        :id                => s['id'],
        :ensure            => :present,
        :smart_proxies     => s['smart_proxies'],
        :compute_resources => s['compute_resources'],
        :media             => s['media'],
        :config_templates  => s['config_templates'],
        :domains           => s['domains'],
        :subnets           => s['subnets'],
        :environments      => s['environments'],
        :locations         => s['locations']
      }
      new(org_hash)
    end
  end

  def self.prefetch(resources)
    organizations = instances
    resources.keys.each do |organization|
      if provider = organizations.find { |o| o.name == organization }
        resources[organization].provider = provider
      end
    end
  end

  def organization_hash(hash)
    organization_hash = {
      :organization => hash
    }
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

  def id
    @property_hash[:id]
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    org_hash = {
      'name'                 => resource[:name],
      'smart_proxy_ids'      => lookup_ids(self.class.smartproxies, resource[:smart_proxies]),
      'compute_resource_ids' => lookup_ids(self.class.compute_resource, resource[:compute_resources]),
      'medium_ids'           => lookup_ids(self.class.media, resource[:media]),
      'config_template_ids'  => lookup_ids(self.class.config_template, resource[:config_templates]),
      'domain_ids'           => lookup_ids(self.class.domain, resource[:domains]),
      'environment_ids'      => lookup_ids(self.class.environment, resource[:environments]),
      'subnet_ids'           => lookup_ids(self.class.subnet, resource[:subnets]),
      'location_ids'         => lookup_ids(self.class.location, resource[:locations]),
    }
    self.class.organizations.create(organization_hash(org_hash))
  end

  def destroy
    self.class.organizations.delete(id)
  end

  def smart_proxies=(value)
    self.class.organizations.update(id, organization_hash(:smart_proxy_ids => lookup_ids(self.class.smartproxies, value)))
  end

  def compute_resources=(value)
    self.class.organizations.update(id, organization_hash(:compute_resource_ids => lookup_ids(self.class.compute_resource, value)))
  end

  def media=(value)
    self.class.organizations.update(id, organization_hash(:medium_ids => lookup_ids(self.class.media, value)))
  end

  def config_templates=(value)
    self.class.organizations.update(id, organization_hash(:config_template_ids => lookup_ids(self.class.config_template, value)))
  end

  def domains=(value)
    self.class.organizations.update(id, organization_hash(:domain_ids => lookup_ids(self.class.domain, value)))
  end

  def environments=(value)
    self.class.organizations.update(id, organization_hash(:environment_ids => lookup_ids(self.class.environment, value)))
  end
  
  def subnets=(value)
    self.class.organizations.update(id, organization_hash(:subnet_ids => lookup_ids(self.class.subnet, value)))
  end

  def locations=(value)
    self.class.organizations.update(id, organization_hash(:location_ids => lookup_ids(self.class.location, value)))
  end
end
