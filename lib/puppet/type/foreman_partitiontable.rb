require 'uri'

Puppet::Type.newtype(:foreman_partitiontable) do

  ensurable

  newparam(:name, :namevar => true) do
    desc ''
  end

  newproperty(:layout) do
    desc ''
    defaultto ''
  end

  newproperty(:os_family) do
    desc ''
    defaultto ''
    newvalues('','AIX','Arch Linux', 'Debian', 'Free BSD', 'Gentoo', 'Junos', 'Redhat', 'Solaris', 'SUSE', 'Windows')
  end

end
