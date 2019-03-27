require 'uri'

Puppet::Type.newtype(:foreman_compute_resource) do

  ensurable

  newparam(:name, :namevar => true) do
    desc ''
  end

  newparam(:provider) do
    desc ''
    defaultto ''
    newvalues('','EC2','Vmware') #TODO: test this
  end

  newproperty(:description) do
    desc ''
    defaultto ''
  end

  newproperty(:user) do
    desc ''
    defaultto ''
  end

  newparam(:password) do
    desc ''
    defaultto ''
  end

  newproperty(:datacenter) do
    desc ''
    defaultto ''
  end

  newproperty(:region) do
    desc ''
    defaultto ''
  end

  newproperty(:server) do
    desc ''
    defaultto ''
  end

end
