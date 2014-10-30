require 'uri'

Puppet::Type.newtype(:foreman_config_template) do

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

  newproperty(:template) do
    desc ''
    defaultto ''
  end

  newproperty(:snippet) do
    desc ''
    defaultto false
  end

  newproperty(:type) do
    desc ''
    newvalues('', 'PXELinux','PXEGrub','iPXE','provision','finish','script','user_data','ZTP')
    defaultto ''
  end

  newproperty(:operatingsystems) do
    desc ''
    defaultto ''
  end
end
