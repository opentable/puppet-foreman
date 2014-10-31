
Puppet::Type.type(:foreman_operatingsystem).provide(:rest) do

  confine :true => begin
    begin
      require 'oauth'
      require 'json'
      require 'puppet_x/theforeman/operatingsystem'
      require 'puppet_x/theforeman/architecture'
      true
    rescue LoadError
      false
    end
  end

  def operatingsystems
    PuppetX::TheForeman::Resources::OperatingSystems.new(resource)
  end

  def operatingsystem
    if @os
      @os
    else
      os = operatingsystems.read
      os_result = os['results'].find { |s| s['description'] == resource[:name] }
      if os_result
        @os = operatingsystems.read(os_result['id'])
      else
        @os = os
      end
    end
  end

  def architecture_lookup(names)
    architectures = []
    archs = PuppetX::TheForeman::Resources::Architectures.new(resource).read
    archs['results'].each do |result|
      names.each do |name|
        if result['name'].eql?(name)
          architectures.push(result)
        end
      end
    end
    return architectures
  end

  def media_lookup(names)
    mediatypes = []
    media = PuppetX::TheForeman::Resources::MediaTypes.new(resource).read
    media['results'].each do |result|
      names.each do |name|
        if result['name'].eql?(name)
          mediatypes.push(result)
        end
      end
    end
    return mediatypes
  end

  def ptable_lookup(names)
    ptables = []
    ptable = PuppetX::TheForeman::Resources::PartitionTables.new(resource).read
    ptable['results'].each do |result|
      names.each do |name|
        if result['name'].eql?(name)
          ptables.push(result)
        end
      end
    end
    return ptables
  end

  def id
    operatingsystem ? operatingsystem['id'] : nil
  end

  def exists?
    id != nil
  end

  def create
    os_hash = {
      'description'   => resource[:name],
      'major'         => resource[:major_version],
      'minor'         => resource[:minor_version],
      'name'          => resource[:osname],
      'release_name'  => resource[:release_name]
    }

    os_hash['architectures'] = architecture_lookup(resource[:architectures]) if !resource[:architectures].empty?
    os_hash['media']         = media_lookup(resource[:media]) if !resource[:media].empty?
    os_hash['ptables']       = ptable_lookup(resource[:ptables]) if !resource[:ptables].empty?
    os_hash['family']        = resource[:osfamily] if !resource[:osfamily]

    operatingsystems.create(os_hash)
  end

  def destroy
    operatingsystems.delete(id)
    @os = nil
  end

  def architectures
    if operatingsystem
      architectures = []
      operatingsystem['architectures'].each do |n|
        architectures.push(n['name'])
      end
      architectures
    else
      nil
    end
  end

  def architectures=(value)
    operatingsystems.update(id, { :architectures => architecture_lookup(value) })
  end

  def media
    if operatingsystem
      mediatypes = []
      operatingsystem['media'].each do |n|
        mediatypes.push(n['name'])
      end
      mediatypes
    else
      nil
    end
  end

  def media=(value)
    operatingsystems.update(id, { :media => media_lookup(value) })
  end

  def ptables
    if operatingsystem
      ptables = []
      operatingsystem['ptables'].each do |n|
        ptables.push(n['name'])
      end
      ptables
    else
      nil
    end
  end

  def ptables=(value)
    operatingsystems.update(id, { :ptables => ptable_lookup(value) })
  end

  def name
    operatingsystem ? operatingsystem['description'] : nil
  end

  def osname
    operatingsystem ? operatingsystem['name'] : nil
  end

  def osname=(value)
    operatingsystems.update(id, { :name => value })
  end

  def major_version
    operatingsystem ? operatingsystem['major'] : nil
  end

  def major_version=(value)
    operatingsystems.update(id, { :major => value })
  end

  def minor_version
    operatingsystem ? operatingsystem['minor'] : nil
  end

  def minor_version=(value)
    operatingsystems.update(id, { :minor => value })
  end

  def release_name
    operatingsystem ? operatingsystem['release_name'] : nil
  end

  def release_name=(value)
    operatingsystems.update(id, { :release_name => value })
  end

end
