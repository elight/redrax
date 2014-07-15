require 'redrax/docs_linkable'

module Redrax
  class Container
    extend Redrax::DocsLinkable
    
    attr_reader :client, :name, :count, :size

    def self.from_hash(client, params = {})
      new(client, *params.values_at("name", "count", "size"))
    end

    def initialize(client, name, count = 0, size = 0)
      @client = client
      @name   = name
      @count  = 0
      @size   = 0
    end

    docs "http://docs.rackspace.com/files/api/v1/cf-devguide/content/GET_listcontainerobjects_v1__account___container__containerServicesOperations_d1e000.html"
    def files(options = {})
      client.request(
        method:   :get,
        path:     name,
        params:   options,
        expected: (200..299)
      )
    end
  end
end
