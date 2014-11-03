require 'oauth'
require 'json'
require 'puppet_x/theforeman/resource'

module PuppetX
module TheForeman
module Resources

  class OSDefaultTemplates < Resource

    def initialize(resource)
      super(resource)
    end

    def create(os_id, template_hash)
      post_data = template_hash.to_json
      consumer.request(:post, "#{resource[:base_url]}/api/v2/operatingsystems/#{os_id}/os_default_templates", token, {}, post_data, headers)
    end

    def read(os_id, id=nil)
      if id
        template = consumer.request(:get, "#{resource[:base_url]}/api/v2/operatingsystems/#{os_id}/os_default_templates/#{id}", token, {})
      else
        template = consumer.request(:get, "#{resource[:base_url]}/api/v2/operatingsystems/#{os_id}/os_default_templates", token, {})
      end

      JSON.parse(template.read_body)
    end

    def update(id, template_hash)
      #TODO:
    end

    def delete(id)
      #TODO:
    end
  end

end
end
end
