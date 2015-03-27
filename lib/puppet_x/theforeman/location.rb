require 'oauth'
require 'json'
require 'puppet_x/theforeman/resource'

module PuppetX
module TheForeman
module Resources

  class Locations < Resource

    def initialize(resource)
      super(resource)
    end

    def create(location_hash)
      post_data = location_hash.to_json
      request(:post, "#{base_url}/api/v2/locations", token, {}, post_data, headers)
    end

    def read(id=nil)
      if id
        location = request(:get, "#{base_url}/api/v2/locations/#{id}", token, {})
      else
        location = request(:get, "#{base_url}/api/v2/locations", token, {})
      end
      JSON.parse(location.read_body)
    end

    def update(id, location_hash)
      post_data = location_hash.to_json
      request(:put, "#{base_url}/api/v2/locations/#{id}", token, {}, post_data, headers)
    end

    def delete(id)
      request(:delete, "#{base_url}/api/v2/locations/#{id}", token, {})
    end
  end

end
end
end
