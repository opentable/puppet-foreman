require 'oauth'
require 'json'
require 'puppet_x/theforeman/resource'

module PuppetX
module TheForeman
module Resources

  class Subnets < Resource

    def initialize(resource)
      super(resource)
    end

    def create(subnet_hash)
      post_data = subnet_hash.to_json
      consumer.request(:post, "#{resource[:base_url]}/api/v2/subnets", token, {}, post_data, headers)
    end

    def read(id=nil)
      if id
        subnet = consumer.request(:get, "#{resource[:base_url]}/api/v2/subnets/#{id}", token, {})
      else
        subnet = consumer.request(:get, "#{resource[:base_url]}/api/v2/subnets", token, {})
      end
      JSON.parse(subnet.read_body)
    end

    def delete(id)
      subnet = consumer.request(:delete, "#{resource[:base_url]}/api/v2/subnets/#{id}", token, {})
    end

    def update(id, subnet_hash)
      post_data = subnet_hash.to_json
      consumer.request(:put, "#{resource[:base_url]}/api/v2/subnets/#{id}", token, {}, post_data, headers)
    end
  end

end
end
end
