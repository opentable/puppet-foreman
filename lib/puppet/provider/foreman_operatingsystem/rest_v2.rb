
Puppet::Type.type(:foreman_operatingsystem).provide(:rest) do

  confine :true => begin
    begin
      require 'oauth'
      require 'json'
      require 'puppet_x/theforeman/operatingsystem'
      require 'puppet_x/theforeman/architecture'
      require 'puppet_x/theforeman/os_default_template'
      require 'puppet_x/theforeman/config_template'
      true
    rescue LoadError
      false
    end
  end

  mk_resource_methods

  def initialize(value={})
    super(value)
  end

  def self.operatingsystems
    PuppetX::TheForeman::Resources::OperatingSystems.new(nil)
  end

  def self.instances
    os_config = operatingsystems.read
    os_config.collect do |s|
      os_hash = {
        :name                 => s['description'],
        :ensure               => :present,
        :id                   => s['id'],
        :osname               => s['name'],
        :major_version        => s['major'],
        :minor_version        => s['minor'],
        :os_family            => s['family'],
        :release_name         => s['release_name'],
        :architectures        => s['architectures'] ? resource_names(s['architectures']) : nil,
        :media                => s['media'] ? resource_names(s['media']) : nil,
        :ptables              => s['ptables'] ? resource_names(s['ptables']) : nil,
        :os_default_templates => s['config_templates'] ? resource_names(s['config_templates']) : nil
      }
      new(os_hash)
    end
  end

  def self.prefetch(resources)
    os_config = instances
    resources.keys.each do |os|
      if provider = os_config.find { |o| o.name == os }
       resources[os].provider = provider 
      end
    end 
  end

  def self.resource_names(res)
    res_list = []
    res.each do |r|
      res_list.push(r['name'])
    end
    res_list.sort!
  end
  
  def architecture_lookup(names)
    architectures = []
    archs = PuppetX::TheForeman::Resources::Architectures.new(nil).read
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
    ptable.each do |result|
      names.each do |name|
        if result['name'].eql?(name)
          ptables.push(result)
        end
      end
    end
    return ptables
  end

  def os_hash(hash)
    os_hash = {
      'operatingsystem' => hash
    }
  end

  #def os_templates_id(name)
  #  od_id = nil
  #  os_template = PuppetX::TheForeman::Resources::ConfigTemplates.new(resource).read
  #  os_template['results'].each do |result|
  #    if result['name'].eql?(name)
  #      os_id = result['id']
  #    end
  #  end
  #  return od_id
  #end
  
  #def os_default_templates_update(names)
  #  os_template = PuppetX::TheForeman::Resources::OSDefaultTemplates.new(nil)
  #  names.each_with_index do |name,index|
  #			config_template = os_templates_lookup([name])[0]
	#		if config_template
  #      ct_id = config_template['id']
  #      ct_kind_id = config_template['template_kind_id']
  #
  #      template_hash = {
  #        'os_default_template' => {
  #          'template_kind_id' => ct_kind_id,
  #          'config_template_id' => ct_id
  #        }
  #      }
  #
  #      results = os_template.read(id)['results']
  #      if results.empty?
  #        os_template.create(id, template_hash)
  #      else
  #        results.each do |result|
  #          if result['config_template_name'].eql?(name)
  #            # TODO: os_template.update
  #          else
  # 	          os_template.create(id, template_hash)
  #          end
  #        end
  #      end
 # 			else
  #				return nil
	#		end
  #  end
  #end

  def os_templates_lookup(names)
    os_templates = []
    os_template = PuppetX::TheForeman::Resources::ConfigTemplates.new(nil).read
    os_template.each do |result|
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
    #os_template = PuppetX::TheForeman::Resources::OSDefaultTemplates.new(nil)
    config_templates = os_templates_lookup(names)
    template_list = []
    config_templates.each do |template|
      default_template_hash = {
        'config_template_id' => template['id'],
        'template_kind_id'   => template['template_kind_id']
      }
      template_list.push(default_template_hash)
    end
    self.class.operatingsystems.update(id, os_hash({ :os_default_template => template_list }))
    self.class.operatingsystems.update(id, os_hash({ :config_templates => template_list }))
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def id
    @property_hash[:id]
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

    self.class.operatingsystems.create(os_hash)
  end

  def destroy
    self.class.operatingsystems.delete(id)
  end

  def id
    @property_hash[:id]
  end

  def architectures=(value)
    self.class.operatingsystems.update(id, { :architectures => architecture_lookup(value) })
  end

  def media=(value)
    self.class.operatingsystems.update(id, { :media => media_lookup(value) })
  end

  def ptables=(value)
    self.class.operatingsystems.update(id, { :ptables => ptable_lookup(value) })
  end

  def os_default_templates=(value)
    os_template_update(value)
  end

  def name=(value)
    self.class.operatingsystems.update(id, { :description => value })
  end

  def osname=(value)
    self.class.operatingsystems.update(id, { :name => value })
  end

  def major_version=(value)
    self.class.operatingsystems.update(id, { :major => value })
  end

  def minor_version=(value)
    self.class.operatingsystems.update(id, { :minor => value })
  end

  def os_family=(value)
    self.class.operatingsystems.update(id, { :family => value })
  end

  def release_name=(value)
    self.class.operatingsystems.update(id, { :release_name => value })
  end

  def architectures=(value)
    self.class.operatingsystems.update(id, { :architectures => value })
  end

  def media=(value)
    self.class.operatingsystems.update(id, { :media => value })
  end

  def ptables=(value)
    self.class.operatingsystems.update(id, { :ptables => value })
  end

  def os_default_templates=(value)
    self.class.operatingsystems.update(id, { :os_default_templates => value })
  end
end
