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

  def subnets
    PuppetX::TheForeman::Resources::Subnets.new(resource)
  end

  def subnet
    subnet = subnets.read
    subnet['results'].each do |s|
      if s['name'] == resource[:name]
        @subnet = subnets.read(s['id'])
        break
      else
        @subnet = nil
      end
    end
    @subnet
  end

  def domain_lookup(names)
    domain = PuppetX::TheForeman::Resources::Domains.new(resource).read
    domains = []
    names.each do |name|
      domain['results'].each do |d|
        if d['name'] == name
          domains.push(d)
        end
      end
    end
    return domains
  end

  def domain_names(domains)
    domain_list = []
    domains.each do |d|
      domain_list.push(d['name'])
    end
    return domain_list
  end

  def proxy_lookup_id(name)
    smartproxy = PuppetX::TheForeman::Resources::SmartProxy.new(resource).read
    proxy = smartproxy['results'].find { |s| s['name'] == name }
    if proxy
      proxy['id']
    else
      nil
    end
  end

  def proxy_name(proxy)
    if proxy
      proxy['name']
    else
      ''
    end
  end

  def id
    subnet ? subnet['id'] : nil
  end

  def exists?
    id != nil
  end

  def create
    subnet_hash = {
      'name'         => resource[:name],
      'network'      => resource[:network_address],
      'mask'         => resource[:network_mask],
      'gateway'      => resource[:gateway_address],
      'dns_primary'  => resource[:primary_dns],
      'dns_scondary' => resource[:secondary_dns],
      'from'         => resource[:start_ip_range],
      'to'           => resource[:end_ip_range],
      'ipam'         => resource[:ipam],
      'vlanid'       => resource[:vlan_id],
      'domains'      => domain_lookup(resource[:domains]),
      'dhcp_id'      => proxy_lookup_id(resource[:dhcp_proxy]),
      'tftp_id'      => proxy_lookup_id(resource[:tftp_proxy]),
      'dns_id'       => proxy_lookup_id(resource[:dns_proxy])
    }

    subnets.create(subnet_hash)
  end

  def destroy
    subnets.delete(id)
    @subnet = nil
  end

  def network_address
    subnet ? subnet['network'] : nil
  end

  def network_address=(value)
    subnets.update(id, { :network => value })
  end

  def network_mask
    subnet ? subnet['mask'] : nil
  end

  def network_mask=(value)
    subnets.update(id, { :mask => value })
  end

  def gateway_address
    subnet ? subnet['gateway'] : nil
  end

  def gateway_address=(value)
    subnets.update(id, { :gateway => value })
  end

  def primary_dns
    subnet ? subnet['dns_primary'] : nil
  end

  def primary_dns=(value)
    subnets.update(id, { :dns_primary => value })
  end

  def secondary_dns
    subnet ? subnet['dns_secondary'] : nil
  end

  def secondary_dns=(value)
    subnets.update(id, { :dns_secondary => value })
  end

  def start_ip_range
    subnet ? subnet['from'] : nil
  end

  def start_ip_range=(value)
    subnets.update(id, { :from => value })
  end

  def end_ip_range
    subnet ? subnet['to'] : nil
  end

  def end_ip_range=(value)
    subnets.update(id, { :to => value })
  end

  def ipam
    subnet ? subnet['ipam'] : nil
  end

  def ipam=(value)
    subnets.update(id, { :ipam => value })
  end

  def vlan_id
    subnet ? subnet['vlanid'] : nil
  end

  def vlan_id=(value)
    subnets.update(id, { :vlanid => value })
  end

  def domains
    subnet ? domain_names(subnet['domains']) : nil
  end

  def domains=(value)
    subnets.update(id, { :domains => domain_lookup(value) })
  end

  def dhcp_proxy
    subnet ? proxy_name(subnet['dhcp']) : nil
  end

  def dhcp_proxy=(value)
    subnets.update(id, { :dhcp_id => proxy_lookup_id(value) })
  end

  def tftp_proxy
    subnet ? proxy_name(subnet['tftp']) : nil
  end

  def tftp_proxy=(value)
    subnets.update(id, { :tftp_id => proxy_lookup_id(value) })
  end

  def dns_proxy
    subnet ? proxy_name(subnet['dns']) : nil
  end

  def dns_proxy=(value)
    subnets.update(id, { :dns_id => proxy_lookup_id(value) })
  end

end
