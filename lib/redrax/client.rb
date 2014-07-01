require 'faraday'
require 'json'

module Redrax
  class Client
    attr_reader :config, :service_catalog, :auth_token

    def configure!(params = {}, &block)
      @config = params.dup
      @config.freeze
      self
    end

    def authenticate!
      @auth_token, @service_catalog = authenticator.call
      self
    end

    private

    def transport
      @transport ||= Transport.new
    end

    def authenticator 
      @authenticator ||= Discovery.new(
        :authenticator,
        :config => config, 
        :transport => transport
      ).call
    end
  end
end
