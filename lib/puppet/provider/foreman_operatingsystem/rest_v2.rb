
Puppet::Type.type(:foreman_operatingsystem).provide(:rest) do

  confine :true => begin
    begin
      require 'oauth'
      require 'json'
      require 'puppet_x/theforeman/operatingsystem'
      require 'puppet_x/theforeman/architecture'
      require 'puppet_x/theforeman/os_default_template'
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

  def os_templates_id(name)
    od_id = nil
    os_template = PuppetX::TheForeman::Resources::ConfigTemplates.new(resource).read
    os_template['results'].each do |result|
      if result['name'].eql?(name)
        os_id = result['id']
      end
    end
    return od_id
  end
  
  def os_default_templates_update(names)
    os_template = PuppetX::TheForeman::Resources::OSDefaultTemplates.new(resource)
    names.each_with_index do |name,index|
			config_template = os_templates_lookup([name])[0]
			if config_template
        ct_id = config_template['id']
        ct_kind_id = config_template['template_kind_id']

        template_hash = {
          'os_default_template' => {
            'template_kind_id' => ct_kind_id,
            'config_template_id' => ct_id
          }
        }

        results = os_template.read(id)['results']
        if results.empty?
          os_template.create(id, template_hash)
        else
          results.each do |result|
            if result['config_template_name'].eql?(name)
              # TODO: os_template.update
            else
   	          os_template.create(id, template_hash)
            end
          end
        end
			else
				return nil
			end
    end
  end

  def os_templates_lookup(names)
    os_templates = []
    os_template = PuppetX::TheForeman::Resources::ConfigTemplates.new(resource).read
    os_template['results'].each do |result|
      names.each do |name|
        if result['name'].eql?(name)
          os_templates.push(result)
          break
        end
      end
    end
    return os_templates
  end

  def os_template_update(names)
    os_id = operatingsystem['id']
    os_template = PuppetX::TheForeman::Resources::OSDefaultTemplates.new(resource)
    names.each do |name|
      config_template = os_templates_lookup(name)[0]
      default_template_hash = {
        'operatingsystem_id'  => os_id,
        'os_default_template' => {
          'config_template_id' => config_template['id'],
          'template_kind_id'   => config_template['template_kind_id']
        }
      }
      os_template.create(os_id, default_template_hash)
    end
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

  def os_default_templates
    if operatingsystem
      config_templates = []
      operatingsystem['os_default_templates'].each do |n|
        config_templates.push(n['config_template_name'])
      end
      config_templates
    else
      nil
    end
  end

  def os_default_templates=(value)
    os_default_templates_update(value)
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
