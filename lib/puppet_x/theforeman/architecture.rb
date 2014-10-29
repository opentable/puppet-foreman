require 'oauth'
require 'json'

module PuppetX
module TheForeman
module Resources

  class Architectures
    attr_reader :resource
    attr_reader :consumer
    attr_reader :headers

    def initialize(resource)
      settings = YAML.load_file('/etc/foreman/settings.yaml')
      @resource = resource

      if @resource[:consumer_key].eql?('')
        consumer_key = settings[:oauth_consumer_key]
      else
        consumer_key = resource[:consumer_key]
      end

      if @resource[:consumer_secret].eql?('')
        consumer_secret = settings[:oauth_consumer_secret]
      else
        consumer_secret = @resource[:consumer_secret]
      end

      oauth_options = {
        :site => @resource[:base_url],
        :request_token_path => '',
        :authorize_path => '',
        :access_token_path => ''
      }

      @headers = {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json'
      }

      @consumer = OAuth::Consumer.new(consumer_key, consumer_secret, oauth_options)
    end

    def create(arch_hash)
      oauth = OAuth::AccessToken.new(@consumer)
      post_data = arch_hash.to_json
      @consumer.request(:post, "#{@resource[:base_url]}/api/v2/architectures", oauth, {}, post_data, @headers)
    end

    def read
      oauth = OAuth::AccessToken.new(@consumer)
      arch = @consumer.request(:get, "#{@resource[:base_url]}/api/v2/architectures", oauth, {})
      JSON.parse(arch.read_body)
    end

    def delete(id)
      oauth = OAuth::AccessToken.new(@consumer)
      arch = @consumer.request(:delete, "#{@resource[:base_url]}/api/v2/architectures/#{id}", oauth, {})
    end
  end
end
end
end
