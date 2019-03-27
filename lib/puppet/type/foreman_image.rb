require 'uri'

Puppet::Type.newtype(:foreman_image) do

  ensurable

  newparam(:name, :namevar => true) do
    desc ''
  end

  newparam(:username) do
    desc ''
    defaultto ''
  end

  newparam(:password) do
    desc ''
    defaultto ''
  end


  newparam(:compute_resource) do
    desc ''
    defaultto ''
  end

  newparam(:architecture) do
    desc ''
    defaultto ''
  end

  newparam(:operatingsystem) do
    desc ''
    defaultto ''
  end
end
