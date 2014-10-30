Puppet::Type.type(:foreman_config_template).provide(:rest) do

  confine :true => begin
    begin
      require 'oauth'
      require 'json'
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
    if @config
      @config
    else
      config = config_templates.read
      config['results'].each do |s|
        if s['name'] == resource[:name]
          @config = config_templates.read(s['id'])
          break
        else
          @config = nil
        end
      end
    end
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
    template = templates.find { |t| t[:name] == name.to_s }[:id]
  end

  def id
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
      'template_kind_name' => resource[:type]
    }

    config_templates.create(config_hash)
  end

  def destroy
    config_templates.delete(id)
    @arch = nil
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
end
