require 'forwardable'

module Redrax
  class CloudFiles
    extend Forwardable

    attr_reader :client

    def_delegators :@client, :configure!, :authenticate!

    def initialize(client = Redrax::Client.new('cloudFiles'))
      @client = client
    end

    DOC_URLS = {
      :list_containers => "http://docs.rackspace.com/files/api/v1/cf-devguide/content/GET_listcontainers_v1__account__accountServicesOperations_d1e000.html",
      :container => "http://docs.rackspace.com/files/api/v1/cf-devguide/content/GET_listcontainerobjects_v1__account___container__containerServicesOperations_d1e000.html"
    }.freeze

    def api_docs(method = nil)
      method = method.to_sym
      DOC_URLS[method]
    end
    
    def list_containers(options = {})
      client.request('', :get, [200, 203], {}, {}, options)
    end
    
    def container(name, options = {})
      client.request(name, :get, (200..299), {}, {}, options)
    end
  end
end
