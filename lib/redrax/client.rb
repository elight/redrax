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

    def request(path, http_method, allowed_statuses = [], params = {}, headers= {}, options = {})
      resp = transport(options[:region])
        .make_request(http_method, path, params, request_headers_with(headers))

      unless allowed_statuses.include?(resp.status)
        fail Exception, "Received status #{resp.status} which is not in #{allowed_statuses.inspect}"
      end 

      JSON.parse(resp.body)
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
    # @params override_region [Symbol] The Rackspace region to connect to. If 
    #   `nil`, defaults to the `Client`'s `#configure!` d region
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
      user_headers.merge(
        'Content-Type' => 'application/json',
        'Accept' => 'application/json'
      ).tap { |h|
        if auth_token
          h['X-Auth-Token'] = auth_token.id
        end
      }
    end
  end
end
