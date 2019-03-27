require 'uri'

Puppet::Type.newtype(:foreman_domain) do

  ensurable

  newparam(:name, :namevar => true) do
    desc ''
  end

  newproperty(:description) do
    desc ''
    defaultto ''
  end

  newproperty(:dns_proxy) do
    desc ''
    defaultto ''
  end

end
