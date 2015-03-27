require 'uri'

Puppet::Type.newtype(:foreman_environment) do

  ensurable

  newparam(:name, :namevar => true) do
    desc ''
  end

end
