module Redrax
  class Files
    extend DocsLinkable
    include PathValidation

    attr_reader :client

    def initialize(client)
      @client = client
    end

    docs "http://docs.rackspace.com/files/api/v1/cf-devguide/content/GET_listcontainerobjects_v1__account___container__containerServicesOperations_d1e000.html"
    # Queries for all of the {File}s matching the query.
    # NOTE: the API documents some default limitations for this API call,
    # e.g., the maximum number of {File}s to return in a single call.
    # @param container_name [String] Name of the container to inspect
    # @return [PaginatedFiles] An Array of {File}s that supports 
    # pagination via the API
    def list(container_name, options = {})
      validate_path_elements(container_name)

      resp = client.request(
        method:   :get,
        path:     container_name,
        params:   options,
        expected: (200..299)
      )
      PaginatedFiles.new(
        resp.map { |f| Redrax::File.from_hash(f) },
        self,
        container_name,
        options
      )
    end

    docs "http://docs.rackspace.com/files/api/v1/cf-devguide/content/PUT_createobject_v1__account___container___object__objectServicesOperations_d1e000.html"
    # Creates an object in Cloud Files
    # @param body [String] The content to place in the Object in Cloud Files.
    # @param args [Hash] Accepts:
    #   * metadata: A Hash of key-value pairs to store as metadata on the Object
    #   * headers: Other non-metadata headers as supported by the API (see api_doc)
    def create(container_name, file_name, body = nil, args = {})
      validate_path_elements(container_name, file_name)

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
    # @param container_name [String] Name of the container to delete the file from
    # @param file_name [String] Name of the file to delete
    def delete(container_name, file_name)
      validate_path_elements(container_name, file_name)

      client.request(
        method:   :delete,
        path:     "#{container_name}/#{file_name}",
        expected: 204
      )
    end

    docs "http://docs.rackspace.com/files/api/v1/cf-devguide/content/GET_getobjectdata_v1__account___container___object__objectServicesOperations_d1e000.html"
    # Gets an object from Cloud Files.
    # @param container_name [String] Name of the container to get the file from
    # @param file_name [String] Name of the file to get
    # TODO: Return metadata as well. Currently returns only the object contents. 
    def get(container_name, file_name)
      validate_path_elements(container_name, file_name)

      File.from_response(
        file_name,
        client.request_raw_response(
          method:       :get,
          path:         "#{container_name}/#{file_name}",
          expected:     200,
        )
      )
    end

    docs "http://docs.rackspace.com/files/api/v1/cf-devguide/content/GET_getobjectdata_v1__account___container___object__objectServicesOperations_d1e000.html"
    # @param container_name [String] Name of the container with the desired file
    # @param file_name [String] Name of the file to get metadata from
    # @return [Hash] The metadata defined on a object. Keys will be 
    #   stripped of their "X-Object-Meta-" prefix, e.g.
    #   "X-Object-Meta-foo" will just be "foo" in the Hash.
    def get_metadata(container_name, file_name)
      validate_path_elements(container_name, file_name)

      MetadataExtractor.new.call(
        "x-object-meta",
        client.request(
          method:   :head,
          path:     "#{container_name}/#{file_name}",
          expected: 200
        )
      )
    end

    docs "http://docs.rackspace.com/files/api/v1/cf-devguide/content/POST_updateaobjmeta_v1__account___container___object__objectServicesOperations_d1e000.html"
    # This is both a delete and update operation. Metadata supplied as arguments
    # to this method replace whatever metadata may already exist on a File.
    # Be aware that this is significantly different from 
    # {Container::update_metadata}.
    # @param file_name [String] Name of the container to update metadata on
    # @param args [Hash] Key-values to set as metadata on this object.
    def replace_metadata(container_name, file_name, args = {})
      validate_path_elements(container_name, file_name)

      client.request(
        method:   :post,
        path:     "#{container_name}/#{file_name}",
        expected: 202,
        headers:  MetadataMarshaller.new.call(
          args,
          "X-Object-Meta-",
          wrong: "X-Remove-Object-Meta-"
        )
      )
    end

    private

    def create_headers_from(args = {})
      args.fetch(:headers, {}).merge(
        MetadataMarshaller.new.call(
          args.fetch(:metadata, {}),
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
