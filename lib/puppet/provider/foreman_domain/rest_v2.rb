Puppet::Type.type(:foreman_domain).provide(:rest) do

  confine :true => begin
    begin
      require 'oauth'
      require 'json'
      require 'puppet_x/theforeman/domain'
      require 'puppet_x/theforeman/smartproxy'
      true
    rescue LoadError
      false
    end
  end

  mk_resource_methods

  def initialize(value={})
    super(value)
  end

  def self.domains
    PuppetX::TheForeman::Resources::Domains.new(nil)
  end

  def self.smartproxies
    PuppetX::TheForeman::Resources::SmartProxy.new(nil)
  end

  def self.instances
    domain_config = domains.read
    domain_config['results'].collect do |s|
       
      dns = smartproxy_lookup_id(s['dns_id'])
      
      domain_hash = {
        :name        => s['name'],
        :id          => s['id'],
        :ensure      => :present,
        :description => s['fullname'],
        :dns_proxy   => dns ? dns['name'] : nil
      }
      new(domain_hash)
    end
  end

  def self.prefetch(resources)
    domains = instances
    resources.keys.each do |domain|
      if provider = domains.find { |d| d.name == domain }
       resources[domain].provider = provider 
      end
    end 
  end

  def self.smartproxy_lookup(name)
    proxy = smartproxies.read
    proxy['results'].find { |s| s['name'] == name }
  end

  def self.smartproxy_lookup_id(id)
    proxy = smartproxies.read
    proxy['results'].find { |s| s['id'] == id }
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    domain_hash = {
      'name'     => resource[:name],
      'fullname' => resource[:description],
    }

    dns = self.class.smartproxy_lookup(resource[:dns_proxy])
    if dns
      domain_hash['dns_id'] = dns['id']
    end

    self.class.domains.create(domain_hash)
  end

  def destroy
    self.class.domains.delete(id)
  end

  def id
    @property_hash[:id]
  end

  def name=(value)
    self.class.domains.update(id, { :name => value })
  end

  def description=(value)
    self.class.domains.update(id, { :fullname => value })
  end

  def dns_proxy=(value)
    dns = self.class.smartproxy_lookup(value)
    if dns
      self.class.domains.update(id, { :dns_id => dns['id'] })
    end
  end

end
