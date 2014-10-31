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
      Puppet.debug("Creating config")
      Puppet.debug("config_hash: #{config_hash}")
      post_data = config_hash.to_json
      consumer.request(:post, "#{resource[:base_url]}/api/v2/config_templates", token, {}, post_data, headers)
    end

    def read(id=nil)
      Puppet.debug("Reading id: #{id}")
      if id
        arch = consumer.request(:get, "#{resource[:base_url]}/api/v2/config_templates/#{id}", token, {})
        Puppet.debug("Arch: #{arch}")
      else
        arch = consumer.request(:get, "#{resource[:base_url]}/api/v2/config_templates?per_page=50", token, {})
      end
      result = JSON.parse(arch.read_body)
      Puppet.debug(result)
      return result
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
