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
      consumer.request(:post, "#{resource[:base_url]}/api/v2/smart_proxies", token, {}, post_data, headers)
    end

    def read
      proxy = consumer.request(:get, "#{resource[:base_url]}/api/v2/smart_proxies", token, {})
      JSON.parse(proxy.read_body)
    end

    def delete(id)
      proxy = consumer.request(:delete, "#{resource[:base_url]}/api/v2/smart_proxies/#{id}", token, {})
    end
  end

end
end
end
