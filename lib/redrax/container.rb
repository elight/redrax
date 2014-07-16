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
      resp = client.request(
        method:   :get,
        path:     name,
        params:   options,
        expected: (200..299)
      )
      PaginatedFiles.new(
        resp.map { |f| Redrax::File.from_hash(client, f) },
        self,
        options
      )
    end
  end

  class PaginatedFiles < PaginatedCollection
    marker_field :name
    collection_method :files
  end
end
