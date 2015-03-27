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
    attr_reader :base_url

    MAX_ATTEMPTS = 5

    def initialize(resource)
      settings = YAML.load_file('/etc/foreman/settings.yaml')

      consumer_key = settings[:oauth_consumer_key]
      consumer_secret = settings[:oauth_consumer_secret]

      require_ssl = settings[:require_ssl]
      url = require_ssl.eql?('true') ? 'https://localhost' : 'http://localhost'

      port = '3000'
      file = File.new('/etc/default/foreman','r')
      while (line = file.gets)
        if line.include?('FOREMAN_PORT') && !line.start_with?('#')
          port = line.split('=')[1]
        end
      end
      file.close

      @base_url = "#{url}:#{port}"

      oauth_options = {
        :site               => base_url,
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
      rescue Timeout::Error => te
        attempts = attempts + 1
        if(attempts < MAX_ATTEMPTS)
          Puppet.warning("Exception calling api. Re-trying ..")
          new_token
          retry
        else
          Puppet.err(te)
        end
      rescue Exception => ex
        msg = "Exception #{ex} in #{method} request to: #{uri}"
        Puppet.err msg
        error = Puppet::Error.new(msg)
        #error.set_backtrace exc.backtrace
        raise error
      end
    end
  end

end
end
end
