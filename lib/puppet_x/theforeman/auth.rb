require 'oauth'
require 'json'
require 'puppet_x/theforeman/resource'

module PuppetX
module TheForeman
module Resources

  class AuthSources < Resource

    def initialize(resource)
      super(resource)
    end

    def create(auth_hash)
      post_data = auth_hash.to_json
      request(:post, "#{base_url}/api/v2/auth_source_ldaps", token, {}, post_data, headers)
    end

    def read
      auth = request(:get, "#{base_url}/api/v2/auth_source_ldaps", token, {})
      JSON.parse(auth.read_body)
    end

    def delete(id)
      request(:delete, "#{base_url}/api/v2/auth_source_ldaps/#{id}", token, {})
    end

    def update(id, auth_hash)
      post_data = auth_hash.to_json
      request(:put, "#{base_url}/api/v2/auth_source_ldaps/#{id}", token, {}, post_data, headers)
    end
  end

end
end
end
