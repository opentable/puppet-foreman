Puppet::Type.type(:foreman_mediatype).provide(:rest) do

  confine :true => begin
    begin
      require 'oauth'
      require 'json'
      require 'puppet_x/theforeman/mediatypes'
      true
    rescue LoadError
      false
    end
  end

  mk_resource_methods
  
  def initialize(value={})
    super(value)
  end

  def self.media_types
    PuppetX::TheForeman::Resources::MediaTypes.new(nil)
  end

  def self.instances
    media_config = media_types.read
    media_config['results'].collect do |s|
      media_hash = {
        :name      => s['name'],
        :id        => s['id'],
        :path      => s['path'],
        :os_family => s['os_family'],
        :ensure    => :present
      }
      new(media_hash)
    end
  end

  def self.prefetch(resources)
    media_types = instances
    resources.keys.each do |media|
      if provider = media_types.find { |m| m.name == media }
        resources[media].provider = provider
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    config_hash = {
      'name'               => resource[:name],
      'path'               => resource[:path],
      'os_family'          => resource[:os_family]
    }

    self.class.media_types.create(config_hash)
  end

  def id
    @property_hash[:id]
  end

  def destroy
    self.class.media_types.delete(id)
  end

  def name=(value)
    self.class.media_types.update(id, { :name => value })
  end

  def path=(value)
    self.class.media_types.update(id, { :path => value })
  end

  def os_family=(value)
    self.class.media_types.update(id, { :os_family => value })
  end

end
