Puppet::Type.type(:foreman_auth).provide(:rest) do

  confine :true => begin
    begin
      require 'oauth'
      require 'json'
      require 'puppet_x/theforeman/auth'
      true
    rescue LoadError
      false
    end
  end

  def auth_sources
    PuppetX::TheForeman::Resources::AuthSources.new(resource)
  end

  def auth_source
    if @auth
      @auth
    else
      auth = auth_sources.read
      @auth = auth['results'].find { |s| s['name'] == resource[:name] }
    end
  end

  def id
    auth_source ? auth_source['id'] : nil
  end

  def exists?
    id != nil
  end

  def to_bool(value)
    value ? "1" : "0"
  end

  def servertype_to_s(name)
    case name.to_s
    when 'POSIX'
      'posix'
    when 'Active Directory'
      'active_directory'
    when 'FreeIPA'
      'free_ipa'
    else
      "unknown - #{name}"
    end
  end

  def string_to_servertype(name)
    case name
    when 'posix'
      'POSIX'
    when 'active_directory'
      'Active Directory'
    when 'free_ipa'
      'FreeIPA'
    else
    end
  end

  def create
    Puppet.debug("HERE")
    auth_hash = {
      'name'              => resource[:name],
      'host'              => resource[:host],
      'tls'               => to_bool(resource[:ldaps]),
      'port'              => resource[:port],
      'server_type'       => servertype_to_s(resource[:server_type]),
      'account'           => resource[:account],
      'base_dn'           => resource[:base_dn],
      'account_password'  => resource[:account_password],
      'attr_login'        => resource[:attr_login],
      'attr_firstname'    => resource[:attr_firstname],
      'attr_lastname'     => resource[:attr_lastname],
      'attr_mail'         => resource[:attr_mail],
      'attr_photo'        => resource[:attr_photo],
      'onthefly_register' => to_bool(resource[:register_users])
    }

    Puppet.debug("END")
    auth_sources.create(auth_hash)
  end

  def destroy
    auth_sources.delete(id)
    @auth = nil
  end

  def host
    auth_source ? auth_source['host'] : nil
  end

  def host=(value)
    auth_sources.update(id, { :host => value })
  end

  def port
    auth_source ? auth_source['port'].to_s : nil
  end

  def port=(value)
    auth_sources.update(id, { :port => value })
  end

  def ldaps
    auth_source ? auth_source['tls'] : nil
  end

  def ldaps=(value)
    auth_sources.update(id, { :tls => value })
  end

  def account
    auth_source ? auth_source['account'] : nil
  end

  def account=(value)
    auth_sources.update(id, { :account => value })
  end

  def base_dn
    auth_source ? auth_source['base_dn'] : nil
  end

  def base_dn=(value)
    auth_sources.update(id, { :base_dn => value })
  end

  def attr_login
    auth_source ? auth_source['attr_login'] : nil
  end

  def attr_login=(value)
    auth_sources.update(id, { :attr_login => value })
  end

  def attr_firstname
    auth_source ? auth_source['attr_firstname'] : nil
  end

  def attr_firstname=(value)
    auth_sources.update(id, { :attr_firstname => value })
  end

  def attr_lastname
    auth_source ? auth_source['attr_lastname'] : nil
  end

  def attr_lastname=(value)
    auth_sources.update(id, { :attr_lastname => value })
  end

  def attr_mail
    auth_source ? auth_source['attr_mail'] : nil
  end

  def attr_mail=(value)
    auth_sources.update(id, { :attr_mail => value })
  end

  def attr_photo
    auth_source ? auth_source['attr_photo'] : nil
  end

  def attr_photo=(value)
    auth_sources.update(id, { :attr_photo => value })
  end

  def register_users
    auth_source ? auth_source['onthefly_register'] : nil
  end

  def register_users=(value)
    auth_sources.update(id, { :onthefly_register => to_bool(value) })
  end

end
