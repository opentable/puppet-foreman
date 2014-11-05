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

  def domains
    PuppetX::TheForeman::Resources::Domains.new(resource)
  end

  def domain
    if @domain
      @domain
    else
      domain = domains.read
      @domain = domain['results'].find { |s| s['name'] == resource[:name] }
    end
  end

  def smartproxies
    PuppetX::TheForeman::Resources::SmartProxy.new(resource)
  end

  def smartproxy_lookup(name)
    proxy = smartproxies.read
    proxy['results'].find { |s| s['name'] == name }
  end

  def smartproxy_lookup_id(id)
    proxy = smartproxies.read
    proxy['results'].find { |s| s['id'] == id }
  end

  def id
    domain ? domain['id'] : nil
  end

  def exists?
    id != nil
  end

  def create
    domain_hash = {
      'name'     => resource[:name],
      'fullname' => resource[:description]
    }

    dns = smartproxy_lookup(resource[:dns_proxy])
    if dns
      domain_hash['dns_id'] = dns['id']
    end

    domains.create(domain_hash)
  end

  def destroy
    domains.delete(id)
    @domain = nil
  end

  def description
    domain ? domain['fullname'] : nil
  end

  def description=(value)
    domains.update(id, { :fullname => value })
  end

  def dns_proxy
    if domain
      dns = smartproxy_lookup_id(domain['dns_id'])
      dns ? dns['name'] : nil
    else
      nil
    end
  end

  def dns_proxy=(value)
    dns = smartproxy_lookup(value)
    if dns
      domains.update(id, { :dns_id => dns['id'] })
    end
  end

end
