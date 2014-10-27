require 'uri'

Puppet::Type.newtype(:foreman_os) do

  ensurable

  newparam(:name, :namevar => true) do
    desc ''
  end

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


  newproperty(:major_version) do
    desc ''
    isrequired
    munge do |value|
      Integer(value)
    end
    newvalues(/^\d{1,2}$/)
  end

  newproperty(:minor_version) do
    desc ''
    defaultto ''
    munge do |value|
      if !value.eql?('')
        Integer(value)
      else
        value
      end
    end
  end

  newproperty(:description) do
    desc ''
    defaultto ''
    newvalues(/^.{0,255}$/)
  end

  newproperty(:osfamily) do
    desc ''
    defaultto ''
    newvalues('','AIX','Arch Linux', 'Debian', 'Free BSD', 'Gentoo', 'Junos', 'Red Hat', 'Solaris', 'SUSE', 'Windows')
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

end
