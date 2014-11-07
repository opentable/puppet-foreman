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

  def organizations_dao
    PuppetX::TheForeman::Resources::Organizations.new(resource)
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

  def location_dao
    PuppetX::TheForeman::Resources::Locations.new(resource)
  end

  def organization
    organization = organizations_dao.read
    organization['results'].each do |s|
      if s['name'] == resource[:name]
        @organization = organizations_dao.read(s['id'])
        break
      else
        @organization = nil
      end
    end
    @organization
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
    organization ? organization['id'] : nil
  end

  def exists?
    id != nil
  end

  def create
    org_hash = {
      'name'                 => resource[:name],
      'smart_proxy_ids'      => lookup_ids(smartproxies_dao, resource[:smart_proxies]),
      'compute_resource_ids' => lookup_ids(compute_resource_dao, resource[:compute_resources]),
      'medium_ids'           => lookup_ids(media_dao, resource[:media]),
      'config_template_ids'  => lookup_ids(config_template_dao, resource[:config_templates]),
      'domain_ids'           => lookup_ids(domain_dao, resource[:domains]),
      'environment_ids'      => lookup_ids(environment_dao, resource[:environments]),
      'subnet_ids'           => lookup_ids(subnet_dao, resource[:subnets]),
      'location_ids'         => lookup_ids(location_dao, resource[:locations]),
    }
    organizations_dao.create(organization_hash(org_hash))
  end

  def destroy
    organizations_dao.delete(id)
    @organization = nil
  end

  def smart_proxies
    organization ? lookup_names(smartproxies_dao, organization['smart_proxies']) : nil
  end

  def smart_proxies=(value)
    organizations_dao.update(id, organization_hash(:smart_proxy_ids => lookup_ids(smartproxies_dao, value)))
  end

  def compute_resources
    organization ? lookup_names(compute_resource_dao, organization['compute_resources']) : nil
  end

  def compute_resources=(value)
    organizations_dao.update(id, organization_hash(:compute_resource_ids => lookup_ids(compute_resource_dao, value)))
  end

  def media
    organization ? lookup_names(media_dao, organization['media']) : nil
  end

  def media=(value)
    organizations_dao.update(id, organization_hash(:medium_ids => lookup_ids(media_dao, value)))
  end

  def config_templates
    organization ? lookup_names(config_template_dao, organization['config_templates']) : nil
  end

  def config_templates=(value)
    organizations_dao.update(id, organization_hash(:config_template_ids => lookup_ids(config_template_dao, value)))
  end

  def domains
    organization ? lookup_names(domain_dao, organization['domains']) : nil
  end

  def domains=(value)
    organizations_dao.update(id, organization_hash(:domain_ids => lookup_ids(domain_dao, value)))
  end

  def environments
    organization ? lookup_names(environment_dao, organization['environments']) : nil
  end

  def environments=(value)
    organizations_dao.update(id, organization_hash(:environment_ids => lookup_ids(environment_dao, value)))
  end

  def subnets
    organization ? lookup_names(subnet_dao, organization['subnets']) : nil
  end

  def subnets=(value)
    organizations_dao.update(id, organization_hash(:subnet_ids => lookup_ids(subnet_dao, value)))
  end

  def locations
    organization ? lookup_names(location_dao, organization['locations']) : nil
  end

  def locations=(value)
    organizations_dao.update(id, organization_hash(:location_ids => lookup_ids(location_dao, value)))
  end
end
