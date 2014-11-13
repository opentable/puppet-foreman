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

  def compute_profiles
    PuppetX::TheForeman::Resources::ComputeProfiles.new(resource)
  end

  def compute_resources
    PuppetX::TheForeman::Resources::ComputeResources.new(resource)
  end

  def compute_profile
    if @profile
      @profile
    else
      profile = compute_profiles.read
      @profile = profile['results'].find { |s| s['name'] == resource[:name] }
    end
  end

  def compute_resource(name)
    resource = compute_resources.read
    resource['results'].find { |s| s['name'] == name }
  end

  def id
    compute_profile ? compute_profile['id'] : nil
  end

  def exists?
    id != nil
  end

  def create
    profile_hash = {
      'name' => resource[:name]
    }

    compute_profiles.create(profile_hash)

    resource[:compute_attributes].each do |name,value|
      comp_resource = compute_resource(name)
      attributes_hash = {
        'compute_attribute' => {
          'compute_profile_id' => id,
          'compute_resource_id' => comp_resource['id'],
          'vm_attrs' => value
        },
        'compute_resource_id' => comp_resource['id']
      }

      compute_attributes = PuppetX::TheForeman::Resources::ComputeAttributes.new(resource)
      compute_attributes.create(id, comp_resource['id'], attributes_hash)
    end

  end

  def destroy
    compute_profiles.delete(id)
    @profile = nil
  end

end
