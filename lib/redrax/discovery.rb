module Redrax 
  class Discovery
    attr_reader :config, :transport, :service

    def initialize(service, params = {})
      @service = service
      @config, @transport = params.values_at(:config, :transport)
    end

    def call
      Redrax.const_get(authenticator_class_name).new(
        :config => config, 
        :transport => transport)
    end    

    def authenticator_class_name
      version = config.fetch(:version, "v2")
      "Authenticator" + version.to_s.capitalize
    end
  end
end
