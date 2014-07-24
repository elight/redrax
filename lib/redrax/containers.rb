require 'delegate'
require 'redrax/docs_linkable'

module Redrax 
  class Containers
    extend DocsLinkable

    attr_reader :client

    def initialize(client)
      @client = client
    end

    docs "http://docs.rackspace.com/files/api/v1/cf-devguide/content/GET_listcontainers_v1__account__accountServicesOperations_d1e000.html"
    # Queries for all of the `Container`s matching the query.
    # NOTE: the API documents some default limitations for this API call,
    # e.g., the maximum number of `Container`s to return in a single call.
    # @return [PaginatedContainers] An `Array` of `Containers` that supports 
    # pagination via the API
    def list(options = {})
      resp = client.request(
        method:   :get,
        path:     '', 
        params:   options,
        expected: [200, 203], 
      )
      PaginatedContainers.new(
        resp.map { |c| Container.from_hash(client, c) }, 
        self,
        nil,
        options
      )
    end

    docs "http://docs.rackspace.com/files/api/v1/cf-devguide/content/PUT_createcontainer_v1__account___container__containerServicesOperations_d1e000.html"
    # Creates a container in Cloud Files.
    # @param name [String] Name of the container to create
    # @param args [Hash] Optional arguments
    #   * metadata: a Hash of key values to store as metadata on the new container
    def create(name, metadata = {})
      client.request(
        method:   :put,
        path:     name,
        expected: [201, 202],
        headers:  MetadataMarshaller.new.call(
          metadata,
          "X-Container-Meta-",
          wrong: "X-Remove-Container-Meta-"
        )
      )
    end

    docs "http://docs.rackspace.com/files/api/v1/cf-devguide/content/DELETE_deletecontainer_v1__account___container__containerServicesOperations_d1e000.html"
    # Deletes a container from Cloud Files
    # @param name [String] Name of the container to delete
    def delete(name)
      client.request(
        method:   :delete,
        path:     name,
        expected: 204
      )
    end

    docs "http://docs.rackspace.com/files/api/v1/cf-devguide/content/HEAD_retrievecontainermeta_v1__account___container__containerServicesOperations_d1e000.html"
    # @param name [String] Name of the container to get metadata from
    # @return [Hash] The metadata defined on a container. Keys will be 
    #   stripped of their "X-Container-Meta-" prefix, e.g.
    #   "X-Container-Meta-foo" will just be "foo" in the `Hash`.
    def get_metadata(name)
      extract_metadata(
        client.request(
          method:   :head,
          path:     name,
          expected: 204
        )
      )
    end

    docs "http://docs.rackspace.com/files/api/v1/cf-devguide/content/POST_updateacontainermeta_v1__account___container__containerServicesOperations_d1e000.html"
    # @param name [String] Name of the container to update metadata on
    # @param args [Hash] Key-values to set as metadata on this container.
    def update_metadata(name, args = {})
      client.request(
        method:   :post,
        path:     name,
        expected: 204,
        headers:  MetadataMarshaller.new.call(
          args,
          "X-Container-Meta-",
          wrong: "X-Remove-Container-Meta-"
        )
      )
    end

    docs "http://docs.rackspace.com/files/api/v1/cf-devguide/content/POST_deletecontainermeta_v1__account___container__containerServicesOperations_d1e000.html"
    # @param name [String] Name of the container to get metadata from
    # @params keys [Array] The list of metadata fields to delete from this 
    #   container.
    def delete_metadata(name, *keys)
      client.request(
        method:   :post,
        path:     name,
        expected: 204,
        headers:  MetadataMarshaller.new.call(
          keys.each_with_object({}) { |k, h| h[k] = 1 },
          "X-Remove-Container-Meta-",
          wrong: "X-Container-Meta-"
        )
      )        
    end

    private

    def extract_metadata(headers)
      headers.each_with_object({}) { |header, h|
        (k, v) = header
        if k =~ /x-container-meta/i
          name = k.gsub(/^x-container-meta-/i, "")
          h[name] = v
        end 
      }
    end

    class PaginatedContainers < PaginatedCollection
      marker_field :name
      collection_method :list
    end
  end
end

