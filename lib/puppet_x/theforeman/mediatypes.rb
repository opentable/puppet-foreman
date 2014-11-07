require 'oauth'
require 'json'
require 'puppet_x/theforeman/resource'

module PuppetX
module TheForeman
module Resources

  class MediaTypes < Resource

    def initialize(resource)
      super(resource)
    end

    def create(media_hash)
      post_data = media_hash.to_json
      request(:post, "#{resource[:base_url]}/api/v2/media", token, {}, post_data, headers)
    end

    def read(id=nil)
      if id
        media = request(:get, "#{resource[:base_url]}/api/v2/media/#{id}", token, {})
      else
        media = request(:get, "#{resource[:base_url]}/api/v2/media", token, {})
      end

      JSON.parse(media.read_body)
    end

    def update(id, media_hash)
      post_data = media_hash.to_json
      request(:put, "#{resource[:base_url]}/api/v2/media/#{id}", token, {}, post_data, headers)
    end

    def delete(id)
      request(:delete, "#{resource[:base_url]}/api/v2/media/#{id}", token, {})
    end
  end

end
end
end
