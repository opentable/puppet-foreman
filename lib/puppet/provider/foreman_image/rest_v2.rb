Puppet::Type.type(:foreman_image).provide(:rest) do

  confine :true => begin
    begin
      require 'oauth'
      require 'json'
      require 'puppet_x/theforeman/image'
      require 'puppet_x/theforeman/compute_resource'
      require 'puppet_x/theforeman/architecture'
      require 'puppet_x/theforeman/operatingsystem'
      true
    rescue LoadError
      false
    end
  end

  def images
    #TODO: fix the NilClass bug here
    PuppetX::TheForeman::Resources::Images.new(resource, compute_resource_lookup(resource[:compute_resource])['id'])
  end

  def compute_resources
    PuppetX::TheForeman::Resources::ComputeResources.new(resource)
  end

  def architectures
    PuppetX::TheForeman::Resources::Architectures.new(resource)
  end

  def operatingsystems
    PuppetX::TheForeman::Resources::OperatingSystems.new(resource)
  end

  def image
    if @image
      @image
    else
      image = images.read
      @image = image['results'].find { |s| s['name'] == resource[:name] }
    end
    @image
  end

  def compute_resource_lookup(name)
    res = compute_resources.read
    results = res['results'].find { |s| s['name'] == name }
  end

  def architecture_lookup(name)
    arch = architectures.read
    results = arch['results'].find { |s| s['name'] == name }
  end

  def operatingsystem_lookup(name)
    os = operatingsystems.read
    results = os['results'].find { |s| s['description'] == name }
  end

  def id
    image ? image['id'] : nil
  end

  def exists?
    id != nil
  end

  def create
    image_hash = {
      'name'                => resource[:name],
      'username'            => resource[:username],
      'password'            => resource[:password],
      'uuid'                => resource[:name],
      'compute_resource_id' => compute_resource_lookup(resource[:compute_resource])['id'],
      'architecture_id'     => architecture_lookup(resource[:architecture])['id'],
      'operatingsystem_id'  => operatingsystem_lookup(resource[:operatingsystem])['id']
    }

    images.create(image_hash)
  end

  def destroy
    images.delete(id)
    @image = nil
  end

  def username
    image ? image['username'] : nil
  end

  def compute_resource
    image ? image['compute_resource'] : nil
  end

  def architecture
    image ? image['architecture'] : nil
  end

  def operatingsystem
    image ? image['operatingsystem'] : nil
  end

end
