require 'oauth'
require 'json'
require 'puppet_x/theforeman/resource'

module PuppetX
module TheForeman
module Resources

  class ConfigTemplates < Resource

    def initialize(resource)
      super(resource)
    end

    def create(config_hash)
      post_data = config_hash.to_json
      request(:post, "#{base_url}/api/v2/config_templates", token, {}, post_data, headers)
      $stdout.write "\n" + post_data + "\n"
    end

    def read
      req = request(:get, "#{base_url}/api/v2/config_templates?per_page=500", token, {})
      t_result = JSON.parse(req.read_body)
      templates = []
      t_result['results'].each do |t|
        id = t['id']
        req = request(:get, "#{base_url}/api/v2/config_templates/#{id}", token, {})
        result = JSON.parse(req.read_body)
        templates.push(result)
      end
      return templates
    end

    def update(id, config_hash)
      post_data = config_hash.to_json
      request(:put, "#{base_url}/api/v2/config_templates/#{id}", token, {}, post_data, headers)
    end

    def delete(id)
      request(:delete, "#{base_url}/api/v2/config_templates/#{id}", token, {})
    end
  end
end
end
end
