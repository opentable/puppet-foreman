
Puppet::Type.type(:foreman_os).provide(:rest) do

  confine :true => begin
    begin
      require 'foreman_api'
      require 'yaml'
      true
    rescue LoadError
      false
    end
  end

  def operatingsystems
    settings = YAML.load_file('/etc/foreman/settings.yaml')

    if resource[:consumer_key].eql?('')
      consumer_key = settings[:oauth_consumer_key]
    else
      consumer_key = resource[:consumer_key]
    end

    if resource[:consumer_secret].eql?('')
      consumer_secret = settings[:oauth_consumer_secret]
    else
      consumer_secret = resource[:consumer_secret]
    end

    operatingsystems = ForemanApi::Resources::OperatingSystem.new({
      :base_url => resource[:base_url],
      :oauth => {
        :consumer_key    => consumer_key,
        :consumer_secret => consumer_secret
      }
    },{
      :headers => {
        :foreman_user => resource[:effective_user],
      }
    })
  end

  def operatingsystem
    if @os
      @os
    else
      os = operatingsystems.index[0]
      if os.is_a?(Hash) && os.has_key?('results')
        # foreman_api 0.1.18+
        @os = os['results'].find { |s| s['name'] == resource[:name] }
      else
        # foreman_api < 0.1.18
        @os = os.find { |s| s['operating_system']['name'] == resource[:name] }['operating_system']
      end
    end
  end

  def id
    operatingsystem ? operatingsystem['id'] : nil
  end

  def exists?
    id != nil
  end

  def create
    Puppet.debug("using architecutures: #{resource[:architectures]}")

    os_hash = {
      'description'  => resource[:description],
      'family'       => resource[:osfamily],
      'major'        => resource[:major_version],
      'minor'        => resource[:minor_version],
      'name'         => resource[:name],
      'release_name' => resource[:release_name]
    }

    os_hash['architectures'] = resource[:architectures] if !resource[:architectures].empty? 

    operatingsystems.create({
      'operatingsystem' => os_hash
    })
  end

  def destroy
    operatingsystems.destroy({'id' => id})
    @os = nil
  end

  def architectures
    operatingsystem ? operatingsystem['architectures'] : nil
  end

  def architectures=(value)
    Puppet.debug("setting architecutures to: #{value}")
    operatingsystems.update({'id' => id, 'operating_system' => {'architectures' => value}})
  end

  def description
    operatingsystem ? operatingsystem['description'] : nil
  end

  def description=(value)
    operatingsystems.update({'id' => id, 'operating_system' => {'description' => value}})
  end

  def osfamily
    operatingsystem ? operatingsystem['osfamily'] : nil
  end

  def osfamily=(value)
    operatingsystems.update({'id' => id, 'operating_system' => {'family' => value}})
  end

  def major_version
    operatingsystem ? operatingsystem['major'] : nil
  end

  def major_version=(value)
    operatingsystems.update({'id' => id, 'operating_system' => {'major' => value}})
  end

  def minor_version
    operatingsystem ? operatingsystem['minor'] : nil
  end

  def minor_version=(value)
    operatingsystems.update({'id' => id, 'operating_system' => {'minor' => value}})
  end

  def name
    operatingsystem ? operatingsystem['name'] : nil
  end

  def name=(value)
    operatingsystems.update({'id' => id, 'operating_system' => {'name' => value}})
  end

  def release_name
    operatingsystem ? operatingsystem['release_name'] : nil
  end

  def release_name=(value)
    operatingsystems.update({'id' => id, 'operating_system' => {'release_name' => value}})
  end

end
