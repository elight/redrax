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

    def files
      @files ||= Files.new(client, self)
    end

    # @return [Redrax::Metadata] The `Metadata` object for this `Container`
    def metadata
      @metadata ||= Metadata.new(client, self)
    end

    docs "http://docs.rackspace.com/files/api/v1/cf-devguide/content/PUT_createcontainer_v1__account___container__containerServicesOperations_d1e000.html"
    def create
      client.request(
        method:   :put,
        path:     name,
        expected: [201, 202]
      )
    end

    # Behavior for manipulating metadata on a container
    class Metadata
      extend Redrax::DocsLinkable

      attr_reader :client, :container_name
      
      def initialize(client, container)
        @client = client
        @container_name = container.name
      end

      docs "http://docs.rackspace.com/files/api/v1/cf-devguide/content/HEAD_retrievecontainermeta_v1__account___container__containerServicesOperations_d1e000.html"
      # @return [Hash] The metadata defined on a container. Keys will be 
      #   stripped of their "X-Container-Meta-" prefix, e.g.
      #   "X-Container-Meta-foo" will just be "foo" in the `Hash`.
      def get
        extract_metadata(
          client.request(
            method:   :head,
            path:     container_name,
            expected: [204]
          )
        )
      end

      docs "http://docs.rackspace.com/files/api/v1/cf-devguide/content/POST_updateacontainermeta_v1__account___container__containerServicesOperations_d1e000.html"
      # @param args [Hash] Key-values to set as metadata on this container.
      def update(args = {})
        headers = MetadataMarshaller.new.call(
          args, 
          "X-Container-Meta-",
          wrong: "X-Remove-Container-Meta-"
        )
        client.request(
          method:   :post,
          path:     container_name,
          headers:  headers,
          expected: [204]
        )
      end

      docs "http://docs.rackspace.com/files/api/v1/cf-devguide/content/POST_deletecontainermeta_v1__account___container__containerServicesOperations_d1e000.html"
      # @params keys [Array] The list of metadata fields to delete from this 
      #   container.
      def delete(*keys)
        headers = MetadataMarshaller.new.call(
          keys.each_with_object({}) { |k, h| h[k] = 1 },
          "X-Remove-Container-Meta-",
          wrong: "X-Container-Meta-"
        )
        client.request(
          method:   :post,
          path:     container_name,
          headers:  headers,
          expected: [204]
        )        
      end

      private

      def extract_metadata(headers)
        headers.each_with_object({}) { |header, h|
          k, v = header[0].downcase, header[1]
          if k =~ /x-container-meta/
            name = k.gsub(/^x-container-meta-/, "")
            h[name] = v
          end 
        }
      end
    end
  end
end
