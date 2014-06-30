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
      authenticator.call
    end

    US_SERVER = 'https://identity.api.rackspacecloud.com'

    def transport
      @transport ||= Faraday.new(:url => US_SERVER)
    end

    def authenticator 
      @authenticator ||= discover_authenticator.new(
        :config => config, 
        :transport => transport
      )
    end

    private

    def discover_authenticator
      version = config.fetch(:version, "v2")
      name = "Authenticator" + version.to_s.capitalize
      Redrax.const_get(name)
    end
  end
end
