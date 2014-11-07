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

  def lookup_by_id(crud_class, id)
    resource = crud_class.read
    resource_name = resource['results'].find { |s| s['id'] == id }
  end

  def lookup_names(crud_class, attribute_array)
    names = []
    unless attribute_array.nil?
      attribute_array.each do |h|
        attribute_object = lookup_by_id(crud_class, h['id'])
        unless attribute_object.nil?
          names.push(attribute_object['name'])
        end
      end
    end
    return names.sort!
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
    locations_dao.delete(id)
    @location = nil
  end

  def smart_proxies
    location ? lookup_names(smartproxies_dao, location['smart_proxies']) : nil
  end

  def smart_proxies=(value)
    locations_dao.update(id, location_hash(:smart_proxy_ids => lookup_ids(smartproxies_dao, value)))
  end

  def compute_resources
    location ? lookup_names(compute_resource_dao, location['compute_resources']) : nil
  end

  def compute_resources=(value)
    locations_dao.update(id, location_hash(:compute_resource_ids => lookup_ids(compute_resource_dao, value)))
  end

  def media
    location ? lookup_names(media_dao, location['media']) : nil
  end

  def media=(value)
    locations_dao.update(id, location_hash(:medium_ids => lookup_ids(media_dao, value)))
  end

  def config_templates
    location ? lookup_names(config_template_dao, location['config_templates']) : nil
  end

  def config_templates=(value)
    locations_dao.update(id, location_hash(:config_template_ids => lookup_ids(config_template_dao, value)))
  end

  def domains
    location ? lookup_names(domain_dao, location['domains']) : nil
  end

  def domains=(value)
    locations_dao.update(id, location_hash(:domain_ids => lookup_ids(domain_dao, value)))
  end

  def environments
    location ? lookup_names(environment_dao, location['environments']) : nil
  end

  def environments=(value)
    locations_dao.update(id, location_hash(:environment_ids => lookup_ids(environment_dao, value)))
  end

  def subnets
    location ? lookup_names(subnet_dao, location['subnets']) : nil
  end

  def subnets=(value)
    locations_dao.update(id, location_hash(:subnet_ids => lookup_ids(subnet_dao, value)))
  end
end
