require 'uri'

Puppet::Type.newtype(:foreman_smartproxy) do

  ensurable

  newparam(:name, :namevar => true) do
    desc ''
  end

  newproperty(:url) do
    desc ''
    defaultto ''
  end

end
