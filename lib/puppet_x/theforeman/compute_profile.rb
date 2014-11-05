require 'oauth'
require 'json'
require 'puppet_x/theforeman/resource'

module PuppetX
module TheForeman
module Resources

  class ComputeProfiles < Resource

    def initialize(resource)
      super(resource)
    end

    def create(compute_hash)
      post_data = compute_hash.to_json
      consumer.request(:post, "#{resource[:base_url]}/api/v2/compute_profiles", token, {}, post_data, headers)
    end

    def read
      compute = consumer.request(:get, "#{resource[:base_url]}/api/v2/compute_profiles", token, {})
      JSON.parse(compute.read_body)
    end

    def delete(id)
      compute = consumer.request(:delete, "#{resource[:base_url]}/api/v2/compute_profiles/#{id}", token, {})
    end

    def update(id, compute_hash)
      post_data = compute_hash.to_json
      consumer.request(:put, "#{resource[:base_url]}/api/v2/compute_profiles/#{id}", token, {}, post_data, headers)
    end
  end

end
end
end
