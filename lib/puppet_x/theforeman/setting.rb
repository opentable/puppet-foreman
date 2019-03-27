require 'oauth'
require 'json'
require 'puppet_x/theforeman/resource'

module PuppetX
module TheForeman
module Resources

  class Settings < Resource

    def initialize(resource)
      super(resource)
    end

    def read
      setting = request(:get, "#{base_url}/api/v2/settings?per_page=500", token, {})
      JSON.parse(setting.read_body)
    end

    def update(id, settings_hash)
      post_data = settings_hash.to_json
      request(:put, "#{base_url}/api/v2/settings/#{id}", token, {}, post_data, headers)
    end
  end

end
end
end
