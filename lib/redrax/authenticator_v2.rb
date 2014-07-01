module Redrax
  # An authenticator is responsible for using the supplied Transport and config
  # to submit a user's credentials to a particular version of the Rackspace 
  # cloud's authentication resource.  It returns an AuthToken and a 
  # ServiceCatalog.
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

      auth_response_json = JSON.parse(resp.body)
      
      [AuthToken.new(auth_response_json), ServiceCatalog.new(auth_response_json)]
    end
  end
end
