require 'uri'

Puppet::Type.newtype(:foreman_mediatype) do

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

  newproperty(:path) do
    desc ''
    defaultto ''
  end

  newproperty(:os_family) do
    desc ''
    defaultto ''
    #TODO: these need to be tested/updated
    newvalues('','AIX','Arch Linux', 'Debian', 'Free BSD', 'Gentoo', 'Junos', 'Redhat', 'Solaris', 'SUSE', 'Windows')
  end

end
