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
      Metadata.new(client)
    end

    class Metadata
      attr_reader :client

      def initialize(client, container, fields = {})
        @client     = client
        @container  = container
        @fields     = fields
        @new_fields = fields.dup
        @dirty      = false
      end

      def [](k)
        @fields[k]
      end

      def [](k, v)
        @dirty = true
        @new_fields[k] = v
      end

      def save!
        fields_added   = @new_fields.keys - @fields.keys
        fields_removed = @fields.keys - @new_fields.keys

        headers = fields_added.each_with_object({}) { |f, h|
          h["X-Container-Meta-#{f}"] = @new_fields[f]
        }
        headers = fields_removed.each_with_object(headers) { |f, h|
          h["X-Remove-Container-Meta-#{f}"] = 1
        }

        client.request(
          method:   :post,
          path:     container.name
          headers:  headers
        )
        @dirty = false
        @fields = @new_fields
    end
  end

  class PaginatedFiles < PaginatedCollection
    marker_field :name
    collection_method :files
  end
end
