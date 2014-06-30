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
      @authenticator ||= Discovery.new(
        :authenticator,
        :config => config, 
        :transport => transport
      ).call
    end
  end
end
