require 'uri'

Puppet::Type.newtype(:foreman_auth) do

  ensurable

  newparam(:name, :namevar => true) do
    desc ''
  end

  newparam(:host) do
    desc ''
    defaultto ''
  end

  newproperty(:ldaps) do
    desc ''
    defaultto false
  end

  newparam(:server_type) do
    desc ''
    defaultto 'POSIX'
    newvalues('POSIX','Active Directory', 'FreeIPA')
  end

  newproperty(:port) do
    desc ''
    defaultto '389'
  end

  newproperty(:account) do
    desc ''
    defaultto ''
  end

  newproperty(:base_dn) do
    desc ''
    defaultto ''
  end

  newparam(:account_password) do
    desc ''
    defaultto ''
  end

  newproperty(:attr_login) do
    desc ''
    defaultto ''
  end

  newproperty(:attr_firstname) do
    desc ''
    defaultto ''
  end

  newproperty(:attr_lastname) do
    desc ''
    defaultto ''
  end

  newproperty(:attr_mail) do
    desc ''
    defaultto ''
  end

  newproperty(:attr_photo) do
    desc ''
    defaultto ''
  end

  newproperty(:register_users) do
    desc ''
    defaultto false
  end
end
