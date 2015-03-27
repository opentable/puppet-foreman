require 'oauth'
require 'json'
require 'puppet_x/theforeman/resource'

module PuppetX
module TheForeman
module Resources

  class PartitionTables < Resource

    def initialize(resource)
      super(resource)
    end

    def create(ptable_hash)
      post_data = ptable_hash.to_json
      request(:post, "#{base_url}/api/v2/ptables", token, {}, post_data, headers)
    end

    def read(id=nil)
      req = request(:get, "#{base_url}/api/v2/ptables?per_page=500", token, {})
      p_result = JSON.parse(req.read_body)
      ptables = []
      p_result['results'].each do |p|
        id = p['id']
        req = request(:get, "#{base_url}/api/v2/ptables/#{id}", token, {})
        result = JSON.parse(req.read_body)
        ptables.push(result)
      end
      return ptables
    end

    def update(id, ptable_hash)
      post_data = ptable_hash.to_json
      request(:put, "#{base_url}/api/v2/ptables/#{id}", token, {}, post_data, headers)
    end

    def delete(id)
      request(:delete, "#{base_url}/api/v2/ptables/#{id}", token, {})
    end
  end

end
end
end
