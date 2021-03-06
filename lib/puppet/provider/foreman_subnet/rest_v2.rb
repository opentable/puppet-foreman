Puppet::Type.type(:foreman_subnet).provide(:rest) do

  confine :true => begin
    begin
      require 'oauth'
      require 'json'
      require 'puppet_x/theforeman/subnet'
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

  def self.subnets
    PuppetX::TheForeman::Resources::Subnets.new(nil)
  end

  def self.domains
    PuppetX::TheForeman::Resources::Domains.new(nil)
  end

  def self.smart_proxies
    PuppetX::TheForeman::Resources::SmartProxy.new(nil)
  end

  def self.instances
    subnet_config = subnets.read
    subnet_config.collect do |s|
      
      subnet_hash = {
        :name            => s['name'],
        :id              => s['id'],
        :ensure          => :present,
        :network_address => s['network'],
        :network_mask    => s['mask'],
        :gateway_address => s['gateway'],
        :primary_dns     => s['dns_primary'],
        :secondary_dns   => s['dns_secondary'],
        :start_ip_range  => s['from'],
        :end_ip_range    => s['to'],
        :vlan_id         => s['vlanid'],
        :domains         => s['domains'] ? domain_names(s['domains']) : nil,
        :dhcp_proxy      => s['dhcp'] ? s['dhcp']['name'] : nil,
        :tftp_proxy      => s['tftp'] ? s['tftp']['name'] : nil,
        :dns_proxy       => s['dns'] ? s['dns']['name'] : nil
      }
      new(subnet_hash)
    end
  end

  def self.prefetch(resources)
    subnets = instances
    resources.keys.each do |subnet|
      if provider = subnets.find { |s| s.name == subnet }
       resources[subnet].provider = provider 
      end
    end 
  end

  def domain_lookup(names)
    domain = self.class.domains.read
    domain_list = []
    names.each do |name|
      domain['results'].each do |d|
        if d['name'] == name
          domain_list.push(d)
        end
      end
    end
    return domain_list
  end

  def self.domain_names(domain_arr)
    domain_list = []
    domain_arr.each do |d|
      domain_list.push(d['name'])
    end
    return domain_list
  end

  def proxy_lookup_id(name)
    smartproxy = self.class.smart_proxies.read
    proxy = smartproxy['results'].find { |s| s['name'] == name }
    if proxy
      proxy['id']
    else
      nil
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    
    subnet_hash = {  
      'name'          => resource[:name],
      'network'       => resource[:network_address],
      'mask'          => resource[:network_mask],
      'gateway'       => resource[:gateway_address],
      'dns_primary'   => resource[:primary_dns],
      'dns_secondary' => resource[:secondary_dns],
      'from'          => resource[:start_ip_range],
      'to'            => resource[:end_ip_range],
      'vlanid'        => resource[:vlan_id],
      'domains'       => domain_lookup(resource[:domains]),
      'dhcp_id'       => proxy_lookup_id(resource[:dhcp_proxy]),
      'tftp_id'       => proxy_lookup_id(resource[:tftp_proxy]),
      'dns_id'        => proxy_lookup_id(resource[:dns_proxy])
    }

    self.class.subnets.create(subnet_hash)
  end

  def destroy
    self.class.subnets.delete(id)
  end

  def id
    @property_hash[:id]
  end

  def network_address=(value)
    self.class.subnets.update(id, { :network => value })
  end

  def network_mask=(value)
    self.subnets.update(id, { :mask => value })
  end

  def gateway_address=(value)
    self.class.subnets.update(id, { :gateway => value })
  end

  def primary_dns=(value)
    self.class.subnets.update(id, { :dns_primary => value })
  end

  def secondary_dns=(value)
    self.class.subnets.update(id, { :dns_secondary => value })
  end

  def start_ip_range=(value)
    self.class.subnets.update(id, { :from => value })
  end

  def end_ip_range=(value)
    self.class.subnets.update(id, { :to => value })
  end

  def vlan_id=(value)
    self.class.subnets.update(id, { :vlanid => value })
  end

  def domains=(value)
    self.class.subnets.update(id, { :domains => domain_lookup(value) })
  end

  def dhcp_proxy=(value)
    self.class.subnets.update(id, { :dhcp_id => proxy_lookup_id(value) })
  end
  
  def tftp_proxy=(value)
    self.class.subnets.update(id, { :tftp_id => proxy_lookup_id(value) })
  end

  def dns_proxy=(value)
    self.class.subnets.update(id, { :dns_id => proxy_lookup_id(value) })
  end

end
