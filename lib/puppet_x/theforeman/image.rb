require 'oauth'
require 'json'
require 'puppet_x/theforeman/resource'

module PuppetX
module TheForeman
module Resources

  class Images < Resource

    def initialize(resource, compute_id)
      super(resource)
      @compute_id = compute_id
    end

    def create(images_hash)
      post_data = images_hash.to_json
      request(:post, "#{resource[:base_url]}/api/v2/compute_resources/#{@compute_id}/images", token, {}, post_data, headers)
    end

    def read
      compute = request(:get, "#{resource[:base_url]}/api/v2/compute_resources/#{@compute_id}/images", token, {})
      JSON.parse(compute.read_body)
    end

    def update(id, compute_hash)
      post_data = compute_hash.to_json
      request(:put, "#{resource[:base_url]}/api/v2/compute_resources/#{@compute_id}/images/#{id}", token, {}, post_data, headers)
    end

    def delete(id)
      request(:delete, "#{resource[:base_url]}/api/v2/compute_resources/#{@compute_id}/images/#{id}", token, {})
    end
  end

end
end
end
