Puppet::Type.type(:foreman_setting).provide(:rest) do

  confine :true => begin
    begin
      require 'oauth'
      require 'json'
      require 'puppet_x/theforeman/setting'
      true
    rescue LoadError
      false
    end
  end

  def settings
    PuppetX::TheForeman::Resources::Settings.new(resource)
  end

  def setting
    if @setting
      @setting
    else
      setting = settings.read
      @setting = setting['results'].find { |s| s['name'] == resource[:name] }
    end
  end

  def id
    setting ? setting['id'] : nil
  end

  def exists?
    id != nil
  end

  def create

  end

  def destroy
    settings.delete(id)
    @setting = nil
  end

  def value
    setting ? setting['value'] : nil
  end

  def value=(data)
    settings.update(id, { :value => data })
  end

end
