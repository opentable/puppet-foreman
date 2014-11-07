require 'oauth'
require 'json'
require 'puppet_x/theforeman/resource'

module PuppetX
module TheForeman
module Resources

  class ComputeResources < Resource

    def initialize(resource)
      super(resource)
    end

    def create(compute_hash)
      post_data = compute_hash.to_json
      request(:post, "#{resource[:base_url]}/api/v2/compute_resources", token, {}, post_data, headers)
    end

    def read
      compute = request(:get, "#{resource[:base_url]}/api/v2/compute_resources", token, {})
      JSON.parse(compute.read_body)
    end

    def delete(id)
      request(:delete, "#{resource[:base_url]}/api/v2/compute_resources/#{id}", token, {})
    end

    def update(id, compute_hash)
      post_data = compute_hash.to_json
      request(:put, "#{resource[:base_url]}/api/v2/compute_resources/#{id}", token, {}, post_data, headers)
    end
  end

end
end
end
