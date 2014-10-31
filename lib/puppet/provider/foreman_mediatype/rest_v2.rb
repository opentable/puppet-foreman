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

  def media_types
    PuppetX::TheForeman::Resources::MediaTypes.new(resource)
  end

  def media_type
    if @media
      @media
    else
      media = media_types.read
      media['results'].each do |s|
        if s['name'] == resource[:name]
          @media = media_types.read(s['id'])
          break
        else
          @media = nil
        end
      end
    end
    @media
  end

  def id
    media_type ? media_type['id'] : nil
  end

  def exists?
    id != nil
  end

  def create
    config_hash = {
      'name'               => resource[:name],
      'path'               => resource[:path],
      'os_family'          => resource[:os_family]
    }

    media_types.create(config_hash)
  end

  def destroy
    media_types.delete(id)
    @media = nil
  end

  def path
    media_type ? media_type['path'] : nil
  end

  def path=(value)
    media_types.update(id, { :path => value })
  end

  def os_family
    media_type ? media_type['os_family'] : nil
  end

  def os_family=(value)
    media_types.update(id, { :os_family => value })
  end

end
