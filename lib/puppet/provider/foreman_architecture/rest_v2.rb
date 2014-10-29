Puppet::Type.type(:foreman_architecture).provide(:rest) do

  confine :true => begin
    begin
      require 'oauth'
      require 'json'
      require 'puppet_x/theforeman/architecture'
      true
    rescue LoadError
      false
    end
  end

  def architectures
    PuppetX::TheForeman::Resources::Architectures.new(resource)
  end

  def architecture
    if @arch
      @arch
    else
      arch = architectures.read
      @arch = arch['results'].find { |s| s['name'] == resource[:name] }
    end
  end

  def id
    architecture ? architecture['id'] : nil
  end

  def exists?
    id != nil
  end

  def create
    arch_hash = {
      'name' => resource[:name]
    }

    architectures.create(arch_hash)
  end

  def destroy
    architectures.delete(id)
    @arch = nil
  end

end
