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
      request(:post, "#{base_url}/api/v2/compute_profiles/#{resource_id}/compute_resources/#{profile_id}/compute_attributes", token, {}, post_data, headers)
    end

    def update(profile_id, resource_id, id, compute_hash)
      post_data = compute_hash.to_json
      request(:put, "#{base_url}/api/v2/compute_profiles/#{resource_id}/compute_resources/#{profile_id}/compute_attributes/#{id}", token, {}, post_data, headers)
    end
  end

end
end
end
