Puppet::Type.type(:foreman_compute_profile).provide(:rest) do

  confine :true => begin
    begin
      require 'oauth'
      require 'json'
      require 'puppet_x/theforeman/compute_profile.rb'
      true
    rescue LoadError
      false
    end
  end

  def compute_profiles
    PuppetX::TheForeman::Resources::ComputeProfiles.new(resource)
  end

  def compute_profile
    if @profile
      @profile
    else
      profile = compute_profiles.read
      @profile = profile['results'].find { |s| s['name'] == resource[:name] }
    end
  end

  def id
    compute_profile ? compute_profile['id'] : nil
  end

  def exists?
    id != nil
  end

  def create
    profile_hash = {
      'name' => resource[:name]
    }

    compute_profiles.create(profile_hash)
  end

  def destroy
    compute_profiles.delete(id)
    @profile = nil
  end

  #def config_attributes
  #  compute_profile ? config_profile['compute_attributes'] : nil
  #end

end
