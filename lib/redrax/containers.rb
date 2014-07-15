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
    def all(options = {})
      resp = client.request(
        method:   :get,
        path:     '', 
        params:   options,
        expected: [200, 203], 
      )
      PaginatedContainers.new(
        resp.map { |c| Container.from_hash(client, c) }, 
        self, 
        options
      )
    end

    # Factory for `Container`s. Does *not* make an API call.
    # @return [Container] the newly created `Container`
    def [](container_name)
      Container.new(client, container_name)
    end
  end

  class PaginatedContainers < PaginatedCollection
    def marker_field
      :name
    end 

    def collection_method
      :all
    end
  end
end

