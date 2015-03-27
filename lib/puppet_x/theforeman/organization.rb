require 'oauth'
require 'json'
require 'puppet_x/theforeman/resource'

module PuppetX
module TheForeman
module Resources

  class Organizations < Resource

    def initialize(resource)
      super(resource)
    end

    def create(organization_hash)
      post_data = organization_hash.to_json
      request(:post, "#{base_url}/api/v2/organizations", token, {}, post_data, headers)
    end

    def read(id=nil)
      if id
        organization = request(:get, "#{base_url}/api/v2/organizations/#{id}", token, {})
      else
        organization = request(:get, "#{base_url}/api/v2/organizations?per_page=500", token, {})
      end
      JSON.parse(organization.read_body)
    end

    def update(id, organization_hash)
      post_data = organization_hash.to_json
      request(:put, "#{base_url}/api/v2/organizations/#{id}", token, {}, post_data, headers)
    end

    def delete(id)
      request(:delete, "#{base_url}/api/v2/organizations/#{id}", token, {})
    end
  end

end
end
end
