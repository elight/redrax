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
      @metadata ||= Metadata.new(client, self)
    end

    class Metadata
      attr_reader :client, :container_name
      
      def initialize(client, container)
        @client = client
        @container_name = container.name
      end

      def get
        client.request(
          method:   :head,
          path:     container_name,
          expected: [204]
        ).each_with_object({}) { |header, h|
          k, v = header[0].downcase, header[1]
          if k =~ /x-container-meta/
            name = k.gsub(/^x-container-meta-/, "")
            h[name] = v
          end 
        }
      end

      def update(args = {})
        headers = prepend_to_keys(args, "X-Container-Meta-")
        client.request(
          method:   :post,
          path:     container_name,
          headers:  headers,
          expected: [204]
        )
      end

      def delete(*keys)
        headers = prepend_to_keys(
          keys.each_with_object({}) { |k, h| h[k] = 1 },
          "X-Remove-Container-Meta-"
        )
        client.request(
          method:   :post,
          path:     container_name,
          headers:  headers,
          expected: [204]
        )        
      end

      private

      def prepend_to_keys(hash, prefix)
        hash.each_with_object({}) { |kv, h|
          k, v = kv[0], kv[1]
          h[prefix + k.to_s] = v.to_s
        }
      end
    end
  end
 
  class PaginatedFiles < PaginatedCollection
    marker_field :name
    collection_method :files
  end
end
