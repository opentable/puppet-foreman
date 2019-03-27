Puppet::Type.type(:foreman_smartproxy).provide(:rest) do

  confine :true => begin
    begin
      require 'oauth'
      require 'json'
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

  def self.smartproxies
    PuppetX::TheForeman::Resources::SmartProxy.new(nil)
  end

  def self.instances
    proxy = smartproxies.read
    proxy['results'].collect do |s|
      proxy_hash = {
        :name   => s['name'],
        :id     => s['id'],
        :ensure => :present,
        :url    => s['url']
      }
      new(proxy_hash)
    end
  end

  def self.prefetch(resources)
    proxies = instances
    resources.keys.each do |proxy|
      if provider = proxies.find { |p| p.name == proxy }
        resources[proxy].provider = provider
      end
    end
  end

  def exists?
    !@property_hash.empty? ? @property_hash[:ensure] = :present : false
  end

  def create
    proxy_hash = {
      'name' => resource[:name],
      'url'  => resource[:url]
    }

    self.class.smartproxies.create(proxy_hash)
  end

  def destroy
    self.class.smartproxies.delete(id)
  end

  def id
    @property_hash[:id]
  end

  def name=(value)
    self.class.smartproxies.update(id, { :name => value })
  end

  def url=(value)
    self.class.smartproxies.update(id, { :url => value })
  end

end
