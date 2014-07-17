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

    def metadata
      @metadata ||= Metadata.new(client)
    end

    class Metadata
      def initialize(client)
        @client = client
      end

      def get
        client.request(
          method:   :head,
          path:     name,
          expected: [204]
        )
      end

      def update(args = {})
        headers = prepend_to_keys(args, "X-Container-Meta-")
        client.request(
          method:   :post
          path:     name,
          headers:  headers,
          expected: [204]
        )
      end

      def delete(*keys)
        headers = prepend_to_keys(args, "X-Remove-Container-Meta-")
        client.request(
          method:   :post
          path:     name,
          headers:  headers,
          expected: [204]
        )        
      end
    end
  end

  class PaginatedFiles < PaginatedCollection
    marker_field :name
    collection_method :files
  end
end
