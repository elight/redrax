module Redrax
  class Files
    extend Redrax::DocsLinkable

    attr_reader :client

    def initialize(client)
      @client = client
    end

    docs "http://docs.rackspace.com/files/api/v1/cf-devguide/content/GET_listcontainerobjects_v1__account___container__containerServicesOperations_d1e000.html"
    # Queries for all of the `File`s matching the query.
    # NOTE: the API documents some default limitations for this API call,
    # e.g., the maximum number of `File`s to return in a single call.
    # @return [PaginatedFiles] An `Array` of `Files` that supports 
    # pagination via the API
    def list(container_name, options = {})
      resp = client.request(
        method:   :get,
        path:     container_name,
        params:   options,
        expected: (200..299)
      )
      PaginatedFiles.new(
        resp.map { |f| Redrax::File.from_hash(client, container_name, f) },
        self,
        container_name,
        options
      )
    end

    docs "http://docs.rackspace.com/files/api/v1/cf-devguide/content/PUT_createobject_v1__account___container___object__objectServicesOperations_d1e000.html"
    # @param body [String] The content to place in the Object in Cloud Files.
    # @param args [Hash] Accepts:
    #   * metadata: A Hash of key-value pairs to store as metadata on the Object
    #   * headers: Other non-metadata headers as supported by the API (see api_doc)
    def create(container_name, file_name, body = nil, args = {})
      client.request(
        method:   :put,
        path:     "#{container_name}/#{file_name}",
        expected: 201,
        params:   {:body => body},
        headers:  create_headers_from(args)
      )
    end

    docs "http://docs.rackspace.com/files/api/v1/cf-devguide/content/DELETE_deleteobject_v1__account___container___object__objectServicesOperations_d1e000.html"
    # Deletes an object from Cloud Files.
    def delete(container_name, file_name)
      client.request(
        method:   :delete,
        path:     "#{container_name}/#{file_name}",
        expected: 204
      )
    end

    docs "http://docs.rackspace.com/files/api/v1/cf-devguide/content/GET_getobjectdata_v1__account___container___object__objectServicesOperations_d1e000.html"
    # Gets an object from Cloud Files.
    # TODO: Return metadata as well. Currently returns only the object contents. 
    def get(container_name, file_name)
      client.request(
        method:   :get,
        path:     "#{container_name}/#{file_name}",
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

  class PaginatedFiles < PaginatedCollection
    marker_field :name
    collection_method :list
  end
end
