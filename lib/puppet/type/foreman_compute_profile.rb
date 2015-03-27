require 'uri'

Puppet::Type.newtype(:foreman_compute_profile) do

  ensurable

  newparam(:name, :namevar => true) do
    desc ''
  end

  newparam(:compute_attributes) do
    desc ''
    defaultto {}
  end

end
