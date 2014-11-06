Puppet::Type.type(:foreman_compute_resource).provide(:rest) do

  confine :true => begin
    begin
      require 'oauth'
      require 'json'
      require 'puppet_x/theforeman/compute_resource'
      true
    rescue LoadError
      false
    end
  end

  def compute_resources
    PuppetX::TheForeman::Resources::ComputeResources.new(resource)
  end

  def compute_resource
    if @res
      @res
    else
      res = compute_resources.read
      @res = res['results'].find { |s| s['name'] == resource[:name] }
    end
  end

  def id
    compute_resource ? compute_resource['id'] : nil
  end

  def exists?
    id != nil
  end

  def create
    compute_hash = {
      'name'        => resource[:name],
      'provider'    => resource[:provider].to_s,
      'description' => resource[:description],
      'user'        => resource[:user],
      'password'    => resource[:password]
    }

    case resource[:provider].to_s
    when /EC2/i
      compute_hash['region'] = resource[:region]
    when /Vmware/i
      compute_hash['datacenter'] = resource[:datacenter]
      compute_hash['server'] = resource[:server]
    else
      Puppet.err("No provider found")
    end

    compute_resources.create(compute_hash)
  end

  def destroy
    compute_resources.delete(id)
    @res = nil
  end

  def description
    compute_resource ? compute_resource['description'] : nil
  end

  def description=(value)
    compute_resources.update(id, { :description => value })
  end

  def user
    if compute_resource
      if compute_resource['provider'].eql?('EC2')
        compute_resource['access_key']
      else
        compute_resource['user']
      end
    else
      nil
    end
  end

  def user=(value)
    compute_resources.update(id, { :user => value })
  end

  def datacenter
    if compute_resource
      if compute_resource['provider'].eql?('EC2')
        ''
      else
        compute_resource['datacenter']
      end
    else
      nil
    end
  end

  def datacenter=(value)
    compute_resources.update(id, { :datacenter => value })
  end

  def region
    if compute_resource
      if compute_resource['provider'].eql?('EC2')
        compute_resource['region']
      else
        ''
      end
    else
      nil
    end
  end

  def region=(value)
    compute_resources.update(id, { :region => value })
  end

  def server
    if compute_resource
      if compute_resource['provider'].eql?('EC2')
        ''
      else
        compute_resource['server']
      end
    else
      nil
    end
  end

  def server=(value)
    compute_resources.update(id, { :server => value })
  end
end
