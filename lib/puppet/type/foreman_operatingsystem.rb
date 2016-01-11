require 'uri'

Puppet::Type.newtype(:foreman_operatingsystem) do

  ensurable

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

end
