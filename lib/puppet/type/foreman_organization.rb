require 'uri'

Puppet::Type.newtype(:foreman_organization) do

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
