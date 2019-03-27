require 'uri'

Puppet::Type.newtype(:foreman_architecture) do

  ensurable

  newparam(:name, :namevar => true) do
    desc ''
  end

end
