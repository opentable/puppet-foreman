require 'uri'

Puppet::Type.newtype(:foreman_config_template) do

  ensurable

  newparam(:name, :namevar => true) do
    desc ''
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

  newproperty(:operatingsystems, :array_matching => :all) do
    desc ''
    defaultto []
    
    def insync?(is)
      is.sort == should.sort
    end
  end
end
