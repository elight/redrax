module Redrax
  class AuthenticatorV2
    attr_reader :transport, :config

    def initialize(params = {})
      @transport = params[:transport]
      @config    = params[:config]
    end

    def call
      body = {
        'auth' => {
          'RAX-KSKEY:apiKeyCredentials' => {
            'username' => config[:user],
            'apiKey'   => config[:api_key]
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
  end
end
