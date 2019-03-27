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
      request(:post, "#{base_url}/api/v2/subnets", token, {}, post_data, headers)
    end

    def read(id=nil)
      #if id
      #  subnet = request(:get, "#{base_url}/api/v2/subnets/#{id}", token, {})
      #else
      #  subnet = request(:get, "#{base_url}/api/v2/subnets", token, {})
      #end
      #JSON.parse(subnet.read_body)

      req = request(:get, "#{base_url}/api/v2/subnets?per_page=500", token, {})
      s_result = JSON.parse(req.read_body)
      subnets = []
      s_result['results'].each do |s|
        id = s['id']
        req = request(:get, "#{base_url}/api/v2/subnets/#{id}", token, {})
        result = JSON.parse(req.read_body)
        subnets.push(result)
      end
      return subnets
    end

    def update(id, subnet_hash)
      post_data = subnet_hash.to_json
      request(:put, "#{base_url}/api/v2/subnets/#{id}", token, {}, post_data, headers)
    end

    def delete(id)
      request(:delete, "#{base_url}/api/v2/subnets/#{id}", token, {})
    end
  end

end
end
end
