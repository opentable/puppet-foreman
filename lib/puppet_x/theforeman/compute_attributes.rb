require 'oauth'
require 'json'
require 'puppet_x/theforeman/resource'

module PuppetX
module TheForeman
module Resources

  class ComputeAttributes < Resource

    def initialize(resource)
      super(resource)
    end

    def create(profile_id, resource_id, compute_hash)
      post_data = compute_hash.to_json
      consumer.request(:post, "#{resource[:base_url]}/api/v2/compute_profiles/#{profile_id}/compute_resources/#{resource_id}/compute_attributes", token, {}, post_data, headers)
    end

    def update(profile_id, resource_id, id, compute_hash)
      post_data = compute_hash.to_json
      consumer.request(:put, "#{resource[:base_url]}/api/v2/compute_profiles/#{profile_id}/compute_resources/#{resource_id}/compute_attributes/#{id}", token, {}, post_data, headers)
    end
  end

end
end
end
