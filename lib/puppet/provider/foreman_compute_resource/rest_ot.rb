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

  mk_resource_methods

  def self.compute_resources
    PuppetX::TheForeman::Resources::ComputeResources.new(nil)
  end

  def initialize(value={})
    super(value)
  end

  def self.instances
    compute_config = compute_resources.read

    compute_config['results'].collect do |s|
      
      compute_hash = {
        :name => s['name'],
        :id   => s['id'],
        :ensure => :present,
        :provider => s['provider'],
        :description => s['description'],
      }

      if s['provider'] == 'EC2'
        compute_hash[:user] = s['access_key']
        compute_hash[:region] = s['region']
        compute_hash[:datacenter] = ''
        compute_hash[:server] = ''
      else
        compute_hash[:user] = s['user']
        compute_hash[:password] = s['password']
        compute_hash[:datacenter] = s['datacenter']
        compute_hash[:server] = s['server']
        compute_hash[:region] = ''
      end
      
      new(compute_hash)
    end
  end

  def self.prefetch(resources)
    compute_resources = instances
    resources.keys.each do |compute_resource|
      if provider = compute_resources.find { |c| c.name == compute_resource }
        resources[compute_resource].provider = provider
      end
    end
  end

  def id
    @property_hash[:id]
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    compute_hash = {
      'compute_resource' => {
        'name'        => resource[:name],
        'provider'    => resource[:provider].to_s,
        'description' => resource[:description],
        'user'        => resource[:user],
        'password'    => resource[:password]
      }
    }

    case resource[:provider].to_s
    when /EC2/i
      compute_hash['compute_resource']['region'] = resource[:region]
    when /Vmware/i
      compute_hash['compute_resource']['datacenter'] = resource[:datacenter]
      compute_hash['compute_resource']['server'] = resource[:server]
    else
      Puppet.err("No provider found")
    end

    self.class.compute_resources.create(compute_hash)
  end

  def destroy
    self.class.compute_resources.delete(id)
  end

  def description=(value)
    self.class.compute_resources.update(id, { :description => value })
  end

  def user=(value)
    self.class.compute_resources.update(id, { :user => value })
  end

  def datacenter=(value)
    self.class.compute_resources.update(id, { :datacenter => value })
  end
  
  def region=(value)
    self.class.compute_resources.update(id, { :region => value })
  end

  def server=(value)
    self.class.compute_resources.update(id, { :server => value })
  end
end
