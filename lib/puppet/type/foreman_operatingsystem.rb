require 'uri'

Puppet::Type.newtype(:foreman_operatingsystem) do

  ensurable

  newparam(:base_url) do
    desc ''
    defaultto 'http://localhost'

    validate do |value|
      unless URI.parse(value).is_a?(URI::HTTP)
        fail("Invalid base_url #{value}")
      end
    end
  end

  newparam(:consumer_key) do
    desc ''
    defaultto ''
  end

  newparam(:consumer_secret) do
    desc ''
    defaultto ''
  end

  newparam(:effective_user) do
    desc ''
    defaultto 'admin'
  end

  newparam(:name, :namevar => true) do
    desc ''
    defaultto ''
  end

  newproperty(:osname) do
    desc ''
    defaultto ''
    newvalues(/^.{0,255}$/)
  end

  newproperty(:major_version) do
    desc ''
    isrequired
    newvalues(/^\d{1,2}$/)
  end

  newproperty(:minor_version) do
    desc ''
    defaultto ''
  end

  newparam(:osfamily) do
    desc ''
    defaultto ''
    #TODO: these need to be tested/updated
    newvalues('','AIX','Arch Linux', 'Debian', 'Free BSD', 'Gentoo', 'Junos', 'Redhat', 'Solaris', 'SUSE', 'Windows')
  end

  newproperty(:release_name) do
    desc ''
    defaultto ''
    newvalues(/^.{0,255}$/)
  end

  newproperty(:architectures, :array_matching => :all) do
    desc ''
    defaultto []
  end

  newproperty(:media, :array_matching => :all) do
    desc ''
    defaultto []
  end

  newproperty(:ptables, :array_matching => :all) do
    desc ''
    defaultto []
  end

  newproperty(:os_default_templates, :array_matching => :all) do
    desc ''
    defaultto []
  end

end
