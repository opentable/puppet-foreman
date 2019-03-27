require 'oauth'
require 'json'
require 'puppet_x/theforeman/resource'

module PuppetX
module TheForeman
module Resources

  class Environments < Resource

    def initialize(resource)
      super(resource)
    end

    def create(env_hash)
      post_data = env_hash.to_json
      request(:post, "#{base_url}/api/v2/environments", token, {}, post_data, headers)
    end

    def read
      env = request(:get, "#{base_url}/api/v2/environments", token, {})
      JSON.parse(env.read_body)
    end

    def delete(id)
      request(:delete, "#{base_url}/api/v2/environments/#{id}", token, {})
    end
  end

end
end
end
