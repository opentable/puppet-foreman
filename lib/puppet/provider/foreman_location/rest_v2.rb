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

  def locations_dao
    PuppetX::TheForeman::Resources::Locations.new(resource)
  end

  def smartproxies_dao
    PuppetX::TheForeman::Resources::SmartProxy.new(resource)
  end

  def compute_resource_dao
    PuppetX::TheForeman::Resources::ComputeResources.new(resource)
  end

  def media_dao
    PuppetX::TheForeman::Resources::MediaTypes.new(resource)
  end

  def config_template_dao
    PuppetX::TheForeman::Resources::ConfigTemplates.new(resource)
  end

  def domain_dao
    PuppetX::TheForeman::Resources::Domains.new(resource)
  end

  def environment_dao
    PuppetX::TheForeman::Resources::Environments.new(resource)
  end

  def subnet_dao
    PuppetX::TheForeman::Resources::Subnets.new(resource)
  end

  def location
    location = locations_dao.read
    location['results'].each do |s|
      if s['name'] == resource[:name]
        @location = locations_dao.read(s['id'])
        break
      else
        @location = nil
      end
    end
    @location
  end

  def location_hash(hash)
    location_hash = {
      :location => hash
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
    location ? location['id'] : nil
  end

  def exists?
    id != nil
  end

  def create
    loc_hash = {
      'name'                 => resource[:name],
      'smart_proxy_ids'      => lookup_ids(smartproxies_dao, resource[:smart_proxies]),
      'compute_resource_ids' => lookup_ids(compute_resource_dao, resource[:compute_resources]),
      'medium_ids'           => lookup_ids(media_dao, resource[:media]),
      'config_template_ids'  => lookup_ids(config_template_dao, resource[:config_templates]),
      'domain_ids'           => lookup_ids(domain_dao, resource[:domains]),
      'environment_ids'      => lookup_ids(environment_dao, resource[:environments]),
      'subnet_ids'           => lookup_ids(subnet_dao, resource[:subnets])
    }
    locations_dao.create(location_hash(loc_hash))
  end

  def destroy
    locations.delete(id)
    @location = nil
  end

  def users

  end

  def users=(value)

  end

  def smart_proxies

  end

  def smart_proxies=(value)
    locations.update(id, location_hash(:smart_proxy_ids => smartproxy_lookup_ids(value)) )
  end

  def compute_resources

  end

  def compute_resources=(value)

  end

  def media

  end

  def media=(value)

  end

  def config_templates

  end

  def config_templates=(value)

  end

  def domains

  end

  def domains=(value)

  end

  def environments

  end

  def environments=(value)

  end

  def subnets

  end

  def subnets=(value)

  end
end
