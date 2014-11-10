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
      request(:post, "#{resource[:base_url]}/api/v2/config_templates", token, {}, post_data, headers)
    end

    def read(id=nil)
      if id
        arch = request(:get, "#{resource[:base_url]}/api/v2/config_templates/#{id}", token, {})
      else
        arch = request(:get, "#{resource[:base_url]}/api/v2/config_templates?per_page=500", token, {})
      end
      result = JSON.parse(arch.read_body)
      return result
    end

    def update(id, config_hash)
      post_data = config_hash.to_json
      request(:put, "#{resource[:base_url]}/api/v2/config_templates/#{id}", token, {}, post_data, headers)
    end

    def delete(id)
      request(:delete, "#{resource[:base_url]}/api/v2/config_templates/#{id}", token, {})
    end
  end
end
end
end
