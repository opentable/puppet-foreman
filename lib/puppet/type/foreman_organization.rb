require 'uri'

Puppet::Type.newtype(:foreman_organization) do

  ensurable

  newparam(:name, :namevar => true) do
    desc ''
  end

  newproperty(:smart_proxies, :array_matching => :all) do
    desc ''
    defaultto []
  end

  newproperty(:compute_resources, :array_matching => :all) do
    desc ''
    defaultto []
  end

  newproperty(:media, :array_matching => :all) do
    desc ''
    defaultto []
  end

  newproperty(:config_templates, :array_matching => :all) do
    desc ''
    defaultto []
  end

  newproperty(:domains, :array_matching => :all) do
    desc ''
    defaultto []
  end

  newproperty(:environments, :array_matching => :all) do
    desc ''
    defaultto []
  end

  newproperty(:subnets, :array_matching => :all) do
    desc ''
    defaultto []
  end

  newproperty(:locations, :array_matching => :all) do
    desc ''
    defaultto []
  end
end
