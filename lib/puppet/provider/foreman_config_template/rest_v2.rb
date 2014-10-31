Puppet::Type.type(:foreman_config_template).provide(:rest) do

  confine :true => begin
    begin
      require 'oauth'
      require 'json'
      require 'puppet_x/theforeman/operatingsystem'
      require 'puppet_x/theforeman/config_template'
      true
    rescue LoadError
      false
    end
  end

  def config_templates
    PuppetX::TheForeman::Resources::ConfigTemplates.new(resource)
  end

  def config_template
    config = config_templates.read
    Puppet.debug("Initial config: #{config}")
    config['results'].each do |s|
      Puppet.debug("Result is #{s}")
      Puppet.debug("name is #{s['name']}")
      Puppet.debug("resource is #{resource[:name]}")
      if s['name'] == resource[:name]
        Puppet.debug("WINNING")
        Puppet.debug("id is #{s['id']}")
        @config = config_templates.read(s['id'])
        break
      else
        @config = nil
      end
    end
    Puppet.debug("Found config: #{@config}")
    @config
  end

  def template_id(name)
    templates = [
      { :id => 1, :name => 'PXELinux'},
      { :id => 2, :name => 'PXEGrub'},
      { :id => 3, :name => 'iPXE'},
      { :id => 4, :name => 'provision'},
      { :id => 5, :name => 'finish'},
      { :id => 6, :name => 'script'},
      { :id => 7, :name => 'user_data'},
      { :id => 8, :name => 'ZTP'}
    ]
    templates.find { |t| t[:name] == name.to_s }[:id]
  end

  def operatingsystem_lookup(names) #TODO: rename names to descriptions
    operatingsystems = PuppetX::TheForeman::Resources::OperatingSystems.new(resource)
    os = operatingsystems.read
    os_names = []
    names.each do |name|
      os_name = os['results'].find { |s| s['description'] == name }
      os_names.push(os_name)
    end
    return os_names
  end

  def os_lookup_by_id(id)
    operatingsystems = PuppetX::TheForeman::Resources::OperatingSystems.new(resource)
    os = operatingsystems.read
    os_name = os['results'].find { |s| s['id'] == id }
  end

  def os_descriptions(os_array)
    names = []
    unless os_array.nil?
      os_array.each do |h|
        os_object = os_lookup_by_id(h['id'])
        Puppet.debug("os_object is: #{os_object}")
        unless os_object.nil?
          names.push(os_object['description'])
        end
      end
    end
    return names
  end

  def id
    Puppet.debug("looking for id")
    Puppet.debug("found config: #{config_template}")
    config_template ? config_template['id'] : nil
  end

  def exists?
    id != nil
  end

  def create
    config_hash = {
      'name'               => resource[:name],
      'template'           => resource[:template],
      'snippet'            => resource[:snippet],
      'template_kind_id'   => template_id(resource[:type]),
      'template_kind_name' => resource[:type],
      'operatingsystems'   => operatingsystem_lookup(resource[:operatingsystems])
    }

    config_templates.create(config_hash)
  end

  def destroy
    config_templates.delete(id)
    @config = nil
  end

  def name
    config_template ? config_template['name'] : nil
  end

  def name=(value)
    config_templates.update(id, { :name => value })
  end

  def template
    config_template ? config_template['template'] : nil
  end

  def template=(value)
    config_templates.update(id, { :template => value })
  end

  def snippet
    config_template ? config_template['snippet'] : nil
  end

  def snippet=(value)
    config_templates.update(id, { :snippet => value })
  end

  def type
    config_template ? config_template['template_kind_name'] : nil
  end

  def type=(value)
    config_templates.update(id, { :template_kind_id => template_id(value), :template_kind_name => value })
  end

  def operatingsystems
    fu = config_template['operatingsystems']
    Puppet.debug("LBENNETT: #{fu}")
    Puppet.debug("LBENNETT: #{fu.class}")
    config_template ? os_descriptions(config_template['operatingsystems']) : nil
  end

  def operatingsystems=(value)
    config_templates.update(id, { :operatingsystems => operatingsystem_lookup(value) })
  end
end
