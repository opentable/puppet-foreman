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
      consumer.request(:post, "#{resource[:base_url]}/api/v2/config_templates", token, {}, post_data, headers)
    end

    def read(id=nil)
      if id
        arch = consumer.request(:get, "#{resource[:base_url]}/api/v2/config_templates/#{id}", token, {})
      else
        arch = consumer.request(:get, "#{resource[:base_url]}/api/v2/config_templates?per_page=50", token, {})
      end
      JSON.parse(arch.read_body)
    end

    def update(id, config_hash)
      post_data = config_hash.to_json
      consumer.request(:put, "#{resource[:base_url]}/api/v2/config_templates/#{id}", token, {}, post_data, headers)
    end

    def delete(id)
      consumer.request(:delete, "#{resource[:base_url]}/api/v2/config_templates/#{id}", token, {})
    end
  end
end
end
end
