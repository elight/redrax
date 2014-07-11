require 'forwardable'

module Redrax
  class CloudFiles
    extend DocsLinkable
    extend Forwardable

    attr_reader :client

    def_delegators :@client, :configure!, :authenticate!

    def initialize(client = Redrax::Client.new('cloudFiles'))
      @client = client
    end

    docs "http://docs.rackspace.com/files/api/v1/cf-devguide/content/GET_listcontainers_v1__account__accountServicesOperations_d1e000.html"
    def list_containers(options = {})
      client.request(
        method:   :get,
        path:     '', 
        expected: [200, 203], 
        options:  options
      )
    end
    
    docs "http://docs.rackspace.com/files/api/v1/cf-devguide/content/GET_listcontainerobjects_v1__account___container__containerServicesOperations_d1e000.html"
    def container(name, options = {})
      client.request(
        method:   :get,
        path:     name,
        expected: (200..299),
        options:  options
      )
    end
  end
end
