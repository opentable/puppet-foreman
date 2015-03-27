require 'oauth'
require 'json'
require 'puppet_x/theforeman/resource'

module PuppetX
module TheForeman
module Resources

  class SmartProxy < Resource

    def initialize(resource)
      super(resource)
    end

    def create(proxy_hash)
      post_data = proxy_hash.to_json
      request(:post, "#{base_url}/api/v2/smart_proxies", token, {}, post_data, headers)
    end

    def read
      proxy = request(:get, "#{base_url}/api/v2/smart_proxies", token, {})
      JSON.parse(proxy.read_body)
    end

    def delete(id)
      request(:delete, "#{base_url}/api/v2/smart_proxies/#{id}", token, {})
    end

    def update(id, config_hash)
      post_data = config_hash.to_json
      request(:put, "#{base_url}/api/v2/smart_proxies/#{id}", token, {}, post_data, headers)
    end
  end

end
end
end
