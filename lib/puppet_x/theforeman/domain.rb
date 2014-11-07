require 'oauth'
require 'json'
require 'puppet_x/theforeman/resource'

module PuppetX
module TheForeman
module Resources

  class Domains < Resource

    def initialize(resource)
      super(resource)
    end

    def create(domain_hash)
      post_data = domain_hash.to_json
      request(:post, "#{resource[:base_url]}/api/v2/domains", token, {}, post_data, headers)
    end

    def read
      domain = request(:get, "#{resource[:base_url]}/api/v2/domains", token, {})
      JSON.parse(domain.read_body)
    end

    def update(id, domain_hash)
      post_data = domain_hash.to_json
      request(:put, "#{resource[:base_url]}/api/v2/domains/#{id}", token, {}, post_data, headers)
    end

    def delete(id)
      request(:delete, "#{resource[:base_url]}/api/v2/domains/#{id}", token, {})
    end
  end

end
end
end
