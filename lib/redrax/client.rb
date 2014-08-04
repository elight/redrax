require 'faraday'
require 'json'

module Redrax
  class Client
    attr_reader :config, :service_catalog, :auth_token, :service

    def initialize(service = nil)
      @service = service
    end

    def configure!(params = {}, &block)
      @config = params.dup
      @config.freeze
      self
    end

    def authenticate!
      @auth_token, @service_catalog = authenticator.call
      self
    end

    def api_docs(method = nil)
      authenticator.api_docs
    end

    # Request paths are prepended, as necessary, with each individual service's 
    # version and the user's account. This prevents redundancy although it can
    # possibly cause confusion when comparing a call to `#request` to 
    # the API docs as the `:path` arg supplied to request specifies the suffix
    # of the path to invoke the particular API call on a service.
    # @param params (Hash) Accepts the following Symbol keys:
    #   * method: the HTTP method to use
    #   * path: the suffix to the API call's path, e.g., v1/{account}/{path is here}
    #   * params: a Hash of arguments to pass on the HTTP request or the body of the HTTP request (depending upon the :method value)
    #   * headers: a Hash of the HTTP headers. Note that Rackspace-specific values are appended to this for user identification purposes
    #   * options: a Hash of options specifically regarding the behavior of the `request` method itself, e.g., specifying a `:region` for a single request differing from the Client's configured region
    def request(options = {})
      resp = request_raw_response(options)
      
      if options[:method] == :head
        resp.headers
      elsif resp.headers["content-type"] =~ /application\/json/i
        JSON.parse(resp.body)
      elsif resp.body.length > 0
        resp.body
      else
        ""
      end
    end

    # Same as `#request` except returns the response object
    # @return [Faraday::Response]
    def request_raw_response(options = {})
      # Need a deep clone here
      params = options.dup
      params[:params] = options.fetch(:params, {}).dup
      params[:headers] = options.fetch(:headers, {}).dup
      
      resp = transport(params[:params].delete(:region))
        .make_request(
          params[:method], 
          params[:path], 
          params[:params], 
          request_headers_with(params[:headers])
        )

      unless Array(params[:expected]).include?(resp.status)
        fail Exception, "Received status #{resp.status} which is not in #{params[:expected].inspect}"
      end 

      resp
    end
    
    def region
      config[:region]
    end

    private

    def auth_transport
      @auth_transport ||= AuthTransport.new
    end

    # Client has one `Transport` per region.  Defaults to the init-time supplied
    # region but favors the `override_region` if present.
    def transport(override_region = nil)
      @transports ||= {}
      r = (override_region || region).to_s.upcase
      @transports[r] ||=
        Transport.new(service, r, service_catalog)
    end

    def authenticator 
      @authenticator ||= Discovery.new(
        :authenticator,
        :config => config, 
        :transport => auth_transport
      ).call
    end

    def request_headers_with(user_headers)
      {
        'Content-Type' => 'application/json',
        'Accept' => 'application/json'
      }.merge(user_headers).tap { |h|
        if auth_token
          h['X-Auth-Token'] = auth_token.id
        end
      }
    end
  end
end
