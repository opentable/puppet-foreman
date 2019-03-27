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

  mk_resource_methods

  def initialize(value={})
    super(value)
  end

  def self.auth_sources
    PuppetX::TheForeman::Resources::AuthSources.new(nil)
  end

  def self.instances
    auth_config = auth_sources.read
    auth_config['results'].collect do |s|
      auth_hash = {
        :name              => s['name'],
        :id                => s['id'],
        :ensure            => :present,
        :host              => s['host'],
        :ldaps             => s['tls'],
        :port              => s['port'].to_s,
        :server_type       => s['server_type'],
        :account           => s['account'],
        :base_dn           => s['base_dn'],
        :account_password  => s['account_password'],
        :attr_login        => s['attr_login'],
        :attr_firstname    => s['attr_firstname'],
        :attr_lastname     => s['attr_lastname'],
        :attr_mail         => s['attr_mail'],
        :attr_photo        => s['attr_photo'],
        :register_users    => s['onthefly_register']
      }
      new(auth_hash)
    end
  end

  def self.prefetch(resources)
    auth_sources = instances
    resources.keys.each do |auth_source|
      if provider = auth_sources.find { |a| a.name == auth_source }
        resources[auth_source].provider = provider
      end
    end
  end

  def id
    @property_hash[:id]
  end

  def exists?
    @property_hash[:ensure] == :present
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

    self.class.auth_sources.create(auth_hash)
  end

  def destroy
    self.class.auth_sources.delete(id)
  end

  def name=(value)
    self.class.auth_sources.update(id, { :name => value })
  end

  def host=(value)
    self.class.auth_sources.update(id, { :host => value })
  end

  def ldaps=(value)
    self.class.auth_sources.update(id, { :tls => to_bool(value) })
  end

  def port=(value)
    self.class.auth_sources.update(id, { :port => value })
  end

  def server_type=(value)
    self.class.auth_sources.update(id, { :server_type => string_to_servertype(value) })
  end

  def account=(value)
    self.class.auth_sources.update(id, { :account => value })
  end

  def base_dn=(value)
    self.class.auth_sources.update(id, { :base_dn => value })
  end

  def attr_login=(value)
    self.class.auth_sources.update(id, { :attr_login => value })
  end

  def attr_firstname=(value)
    self.class.auth_sources.update(id, { :attr_firstname => value })
  end

  def attr_lastname=(value)
    self.class.auth_sources.update(id, { :attr_lastname => value })
  end

  def attr_mail=(value)
    self.class.auth_sources.update(id, { :attr_mail => value })
  end

  def attr_photo=(value)
    self.class.auth_sources.update(id, { :attr_photo => value })
  end

  def register_users=(value)
    self.class.auth_sources.update(id, { :onthefly_register => to_bool(value) })
  end

end
