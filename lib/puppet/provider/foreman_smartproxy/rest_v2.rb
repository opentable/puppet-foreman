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

  def smartproxies
    PuppetX::TheForeman::Resources::SmartProxy.new(resource)
  end

  def smartproxy
    if @proxy
      @proxy
    else
      proxy = smartproxies.read
      Puppet.debug("LBENNETT: ")
      Puppet.debug(proxy)
      Puppet.debug(proxy['results'])
      Puppet.debug("LBENNETT:")
      @proxy = proxy['results'].find { |s| s['name'] == resource[:name] }
    end
  end

  def id
    smartproxy ? smartproxy['id'] : nil
  end

  def exists?
    id != nil
  end

  def create
    proxy_hash = {
      'name' => resource[:name],
      'url'  => resource[:url]
    }

    smartproxies.create(proxy_hash)
  end

  def destroy
    smartproxies.delete(id)
    @proxy = nil
  end

  def url
    smartproxy ? smartproxy['url'] : nil
  end

  def url=(value)
    smartproxies.update(id, { :url => value })
  end

end
