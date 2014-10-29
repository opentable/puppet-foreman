require 'oauth'
require 'json'

module PuppetX
module TheForeman
module Resources

  class OperatingSystems
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

    def create(os_hash)
      oauth = OAuth::AccessToken.new(@consumer)
      post_data = os_hash.to_json
      @consumer.request(:post, "#{@resource[:base_url]}/api/v2/operatingsystems", oauth, {}, post_data, @headers)
    end

    def read(id=nil)
      oauth = OAuth::AccessToken.new(@consumer)

      if id
        os = @consumer.request(:get, "#{@resource[:base_url]}/api/v2/operatingsystems/#{id}", oauth, {})
      else
        os = @consumer.request(:get, "#{@resource[:base_url]}/api/v2/operatingsystems", oauth, {})
      end

      JSON.parse(os.read_body)
    end

    def update(id, os_hash)
      oauth = OAuth::AccessToken.new(@consumer)
      post_data = os_hash.to_json
      @consumer.request(:put, "#{@resource[:base_url]}/api/v2/operatingsystems/#{id}", oauth, {}, post_data, @headers)
    end

    def delete(id)
      oauth = OAuth::AccessToken.new(@consumer)
      os = @consumer.request(:delete, "#{@resource[:base_url]}/api/v2/operatingsystems/#{id}", oauth, {})
    end
  end
end
end
end
