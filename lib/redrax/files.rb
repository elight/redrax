module Redrax
  class Files
    extend Redrax::DocsLinkable

    attr_reader :client, :container

    def initialize(client, container)
      @client = client
      @container = container
    end

    docs "http://docs.rackspace.com/files/api/v1/cf-devguide/content/GET_listcontainerobjects_v1__account___container__containerServicesOperations_d1e000.html"
    # Queries for all of the `File`s matching the query.
    # NOTE: the API documents some default limitations for this API call,
    # e.g., the maximum number of `File`s to return in a single call.
    # @return [PaginatedFiles] An `Array` of `Files` that supports 
    # pagination via the API
    def list(options = {})
      resp = client.request(
        method:   :get,
        path:     container.name,
        params:   options,
        expected: (200..299)
      )
      PaginatedFiles.new(
        resp.map { |f| Redrax::File.from_hash(client, container, f) },
        self,
        options
      )
    end

    # Factory for `Redrax::File`s. Does *not* make an API call.
    # @return [File] the newly created `Redrax::File`
    def [](name)
      File.new(client, container, name)
    end
  end

  class PaginatedFiles < PaginatedCollection
    marker_field :name
    collection_method :list
  end
end
