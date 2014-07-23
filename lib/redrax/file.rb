module Redrax
  class File
    extend Redrax::DocsLinkable

    attr_reader :name, :bytes, :content_type, :last_modified, :hash, :client, :container

    def self.from_hash(client, container, hash = {})
      new(client, container, *hash.values_at('name', 'bytes', 'content_type', 'last_modified', 'hash'))
    end

    def initialize(client, container, name, bytes = nil, content_type = nil, last_modified = nil, hash = nil)
      @client = client
      @container = container
      @name, @bytes, @content_type, @last_modified, @hash = 
        name, bytes, content_type, last_modified, hash
    end

    docs "http://docs.rackspace.com/files/api/v1/cf-devguide/content/PUT_createobject_v1__account___container___object__objectServicesOperations_d1e000.html"
    # @param body [String] The content to place in the Object in Cloud Files.
    # @param args [Hash] Accepts:
    #   * metadata: A Hash of key-value pairs to store as metadata on the Object
    #   * headers: Other non-metadata headers as supported by the API (see api_doc)
    def create(body = nil, args = {})
      client.request(
        method:   :put,
        path:     "#{container.name}/#{name}",
        expected: 201,
        params:   {:body => body},
        headers:  create_headers_from(args)
      )
    end

    docs "http://docs.rackspace.com/files/api/v1/cf-devguide/content/DELETE_deleteobject_v1__account___container___object__objectServicesOperations_d1e000.html"
    # Deletes an object from Cloud Files.
    def delete
      client.request(
        method:   :delete,
        path:     "#{container.name}/#{name}",
        expected: 204
      )
    end

    docs "http://docs.rackspace.com/files/api/v1/cf-devguide/content/GET_getobjectdata_v1__account___container___object__objectServicesOperations_d1e000.html"
    # Gets an object from Cloud Files.
    # TODO: Return metadata as well. Currently returns only the object contents. 
    def get
      client.request(
        method:   :get,
        path:     "#{container.name}/#{name}",
        expected: 200
      )
    end

    private

    def create_headers_from(args = {})
      args.fetch(:headers, {}).merge(
        MetadataMarshaller.new.call(
          args[:metadata],
          "X-Object-Meta-",
          wrong: "X-Remove-Object-Meta-"
        )
      )
    end
  end
end
