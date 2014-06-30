require 'faraday'
require 'json'

module Redrax
  class Client
    attr_reader :config

    def configure!(params = {}, &block)
      @config = params.dup
      @config.freeze
      self
    end

    def authenticate!
      body = {
        'auth' => {
          'RAX-KSKEY:apiKeyCredentials' => {
            'username' => @config[:user],
            'apiKey'   => @config[:api_key]
          }
        }
      }
      resp = transport.post do |r|
        r.url     '/v2.0/tokens'
        r.headers['Content-Type'] = 'application/json'
        r.body = body.to_json
      end

      exception = 
        case resp.status
        when 401
          UnauthorizedException
        end
      raise exception if exception
    end

    US_SERVER = 'https://identity.api.rackspacecloud.com'

    def transport
      @transport ||= Faraday.new(:url => US_SERVER)
    end
  end
end
