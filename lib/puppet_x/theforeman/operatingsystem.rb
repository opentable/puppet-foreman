require 'oauth'
require 'json'
require 'puppet_x/theforeman/resource'

module PuppetX
module TheForeman
module Resources

  class OperatingSystems < Resource

    def initialize(resource)
      super(resource)
    end

    def create(os_hash)
      post_data = os_hash.to_json
      request(:post, "#{base_url}/api/v2/operatingsystems", token, {}, post_data, headers)
    end

    def read
      req = request(:get, "#{base_url}/api/v2/operatingsystems", token, {})
      o_result = JSON.parse(req.read_body)
      os_list = []
      o_result['results'].each do |os|
        id = os['id']
        req = request(:get, "#{base_url}/api/v2/operatingsystems/#{id}", token, {})
        result = JSON.parse(req.read_body)
        os_list.push(result)
      end
      os_list
    end

    def update(id, os_hash)
      post_data = os_hash.to_json
      request(:put, "#{base_url}/api/v2/operatingsystems/#{id}", token, {}, post_data, headers)
    end

    def delete(id)
      request(:delete, "#{base_url}/api/v2/operatingsystems/#{id}", token, {})
    end
  end

end
end
end
