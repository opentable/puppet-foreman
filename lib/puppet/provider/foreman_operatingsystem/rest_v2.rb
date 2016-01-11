
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

#  def media_lookup(names)
#    mediatypes = []
#    media = PuppetX::TheForeman::Resources::MediaTypes.new(resource).read
#    media['results'].each do |result|
#      names.each do |name|
#        if result['name'].eql?(name)
#          mediatypes.push(result)
#        end
#      end
#    end
#    return mediatypes
#  end
#
  def mediaid_lookup(media_name_array)
    mediaids = []
    #look up the media from puppet_x
    media = PuppetX::TheForeman::Resources::MediaTypes.new(resource).read
    #for each result from the lookup, do test on the result
    media['results'].each do |result|
      #for each name in the array from puppet manifest test name
      media_name_array.each do |name|
        #if the result name from the puppet_x lookup matches the name from the manifest array
        if result['name'].eql?(name)
          #push
          mediaids.push(result['id'])
        end
      end
    end
    return mediaids
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
    config_templates = os_templates_lookup(names)
    template_list = []
    config_templates.each do |template|
      default_template_hash = {
        'config_template_id' => template['id'],
        'template_kind_id'   => template['template_kind_id']
      }
      template_list.push(default_template_hash)
    end
    self.class.operatingsystems.update(id, os_hash({ :config_templates => template_list }))
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def id
    @property_hash[:id]
  end

  def create
    os_hash = {"operatingsystem" => {
      'description'   => resource[:name],
      'major'         => resource[:major_version],
      'minor'         => resource[:minor_version],
      'name'          => resource[:osname],
      'release_name'  => resource[:release_name]
      }
    }

    os_hash['architectures'] = architecture_lookup(resource[:architectures]) if !resource[:architectures].empty?
    os_hash['media']         = mediaid_lookup(resource[:id]) if !resource[:id].empty?
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
    self.class.operatingsystems.update(id, {"operatingsystem" => { :architectures => architecture_lookup(value) }})
  end

  def media=(value)
    self.class.operatingsystems.update(id, {"operatingsystem" => { :medium_ids => mediaid_lookup(value) }})
  end

  def ptables=(value)
    self.class.operatingsystems.update(id, {"operatingsystem" => { :ptables => ptable_lookup(value) }})
  end

  def name=(value)
    self.class.operatingsystems.update(id, {"operatingsystem" => { :description => value }})
  end

  def osname=(value)
    self.class.operatingsystems.update(id, {"operatingsystem" => { :name => value }})
  end

  def major_version=(value)
    self.class.operatingsystems.update(id, {"operatingsystem" => { :major => value }})
  end

  def minor_version=(value)
    self.class.operatingsystems.update(id, {"operatingsystem" => { :minor => value }})
  end

  def os_family=(value)
    self.class.operatingsystems.update(id, {"operatingsystem" => { :family => value }})
  end

  def release_name=(value)
    self.class.operatingsystems.update(id, {"operatingsystem" => { :release_name => value }})
  end

 # def architectures=(value)
 #   self.class.operatingsystems.update(id, { :architectures => value })
 # end

  #def media=(value)
  #  self.class.operatingsystems.update(id, { :media => value })
  #end

  #def ptables=(value)
  #  self.class.operatingsystems.update(id, { :ptables => value })
  #end
end
