require 'faraday'
require 'json'

module Redrax
  class Client
    attr_reader :config, :service_catalog, :auth_token, :region, :service

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

    def request(path, http_method, params = {}, headers= {}, options = {})
      headers = {
         'Content-Type' => 'application/json',
        'Accept' => 'application/json'
      }
      if auth_token
        headers['X-Auth-Token'] = auth_token.id
      end

      trans = transport(options[:region])

      # Faraday has different semantics between the various verbs
      # Probably need to abstract this better...
      if [:post, :put, :patch].include?(http_method) 
        trans.send(http_method) do |r|
          r.headers.merge!(headers)
          r.url = path_prefix ? "#{path_prefix}/#{path}" : path
          r.body = params.to_json
        end
      else
        trans.send(http_method, path, params, headers)
      end
    end


    private

    def auth_transport
      @auth_transport ||= AuthTransport.new
    end

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
  end
end
