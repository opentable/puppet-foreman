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
      consumer.request(:post, "#{resource[:base_url]}/api/v2/locations", token, {}, post_data, headers)
    end

    def read(id=nil)
      if id
        location = consumer.request(:get, "#{resource[:base_url]}/api/v2/locations/#{id}", token, {})
      else
        location = consumer.request(:get, "#{resource[:base_url]}/api/v2/locations", token, {})
      end
      JSON.parse(location.read_body)
    end

    def delete(id)
      location = consumer.request(:delete, "#{resource[:base_url]}/api/v2/locations/#{id}", token, {})
    end

    def update(id, location_hash)
      post_data = location_hash.to_json
      consumer.request(:put, "#{resource[:base_url]}/api/v2/locations/#{id}", token, {}, post_data, headers)
    end
  end

end
end
end
