require 'uri'

Puppet::Type.newtype(:foreman_subnet) do

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

  newproperty(:network_address) do
    desc ''
    defaultto ''
  end

  newproperty(:network_mask) do
    desc ''
    defaultto ''
  end

  newproperty(:gateway_address) do
    desc ''
    defaultto ''
  end

  newproperty(:primary_dns) do
    desc ''
    defaultto ''
  end

  newproperty(:secondary_dns) do
    desc ''
    defaultto ''
  end

  newproperty(:start_ip_range) do
    desc ''
    defaultto ''
  end

  newproperty(:end_ip_range) do
    desc ''
    defaultto ''
  end

  newproperty(:ipam) do
    desc ''
    defaultto true
  end

  newproperty(:vlan_id) do
    desc ''
    defaultto ''
  end

  newproperty(:domains, :array_matching => :all) do
    desc ''
    defaultto []
  end

  newproperty(:dhcp_proxy) do
    desc ''
    defaultto ''
  end

  newproperty(:tftp_proxy) do
    desc ''
    defaultto ''
  end

  newproperty(:dns_proxy) do
    desc ''
    defaultto ''
  end

end
