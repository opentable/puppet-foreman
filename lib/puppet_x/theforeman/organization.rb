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
      consumer.request(:post, "#{resource[:base_url]}/api/v2/organizations", token, {}, post_data, headers)
    end

    def read(id=nil)
      if id
        organization = consumer.request(:get, "#{resource[:base_url]}/api/v2/organizations/#{id}", token, {})
      else
        organization = consumer.request(:get, "#{resource[:base_url]}/api/v2/organizations", token, {})
      end
      JSON.parse(organization.read_body)
    end

    def delete(id)
      organization = consumer.request(:delete, "#{resource[:base_url]}/api/v2/organizations/#{id}", token, {})
    end

    def update(id, organization_hash)
      post_data = organization_hash.to_json
      consumer.request(:put, "#{resource[:base_url]}/api/v2/organizations/#{id}", token, {}, post_data, headers)
    end
  end

end
end
end
