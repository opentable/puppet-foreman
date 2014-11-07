require 'oauth'
require 'json'
require 'puppet_x/theforeman/resource'

module PuppetX
module TheForeman
module Resources

  class Architectures < Resource

    def initialize(resource)
      super(resource)
    end

    def create(arch_hash)
      post_data = arch_hash.to_json
      request(:post, "#{resource[:base_url]}/api/v2/architectures", token, {}, post_data, headers)
    end

    def read
      arch = request(:get, "#{resource[:base_url]}/api/v2/architectures", token, {})
      JSON.parse(arch.read_body)
    end

    def delete(id)
      request(:delete, "#{resource[:base_url]}/api/v2/architectures/#{id}", token, {})
    end
  end

end
end
end
