require 'oauth'
require 'json'
require 'yaml'

module PuppetX
module TheForeman
module Resources

  class Resource
    attr_reader :resource
    attr_reader :consumer
    attr_reader :headers
    attr_reader :token

    MAX_ATTEMPTS = 10

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
        :site               => @resource[:base_url],
        :request_token_path => '',
        :authorize_path     => '',
        :access_token_path  => ''
      }

      @headers = {
        'Accept'       => 'application/json',
        'Content-Type' => 'application/json'
      }

      @consumer = OAuth::Consumer.new(consumer_key, consumer_secret, oauth_options)
      @token = OAuth::AccessToken.new(@consumer)
    end

    def new_token
      @token = OAuth::AccessToken.new(@consumer)
    end

    def request(method, uri, token, params, data=nil, headers=nil)
      attempts = 0
      begin
        consumer.request(method, uri, token, params, data, headers)
      rescue Exception => ex
        Puppet.err(ex)
        attempts = attempts + 1
        if(attempts < MAX_ATTEMPTS)
          new_token
          retry
        end
      end
    end
  end

end
end
end
