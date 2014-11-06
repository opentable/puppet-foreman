Puppet::Type.type(:foreman_environment).provide(:rest) do

  confine :true => begin
    begin
      require 'oauth'
      require 'json'
      require 'puppet_x/theforeman/environment'
      true
    rescue LoadError
      false
    end
  end

  def environments
    PuppetX::TheForeman::Resources::Environments.new(resource)
  end

  def environment
    if @env
      @env
    else
      env = environments.read
      @env = env['results'].find { |s| s['name'] == resource[:name] }
    end
  end

  def id
    environment ? environment['id'] : nil
  end

  def exists?
    id != nil
  end

  def create
    env_hash = {
      'name' => resource[:name]
    }

    environments.create(env_hash)
  end

  def destroy
    environments.delete(id)
    @arch = nil
  end

end
