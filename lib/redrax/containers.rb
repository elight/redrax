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
    def all(options = {})
      resp = client.request(
        method:   :get,
        path:     '', 
        params:   options,
        expected: [200, 203], 
      )
      PaginatedContainers.new(resp, self, options)
    end
    
    docs "http://docs.rackspace.com/files/api/v1/cf-devguide/content/GET_listcontainerobjects_v1__account___container__containerServicesOperations_d1e000.html"
    def container(name, options = {})
      client.request(
        method:   :get,
        path:     name,
        params:   options,
        expected: (200..299),
      )
    end
  end
end

class PaginatedContainers < SimpleDelegator
  attr_reader :containers, :options
  
  def initialize(results, containers, options = {:limit => 10_000})
    super(results)
    @containers = containers
    @options    = options
  end

  def next_page
    containers.all(options.merge(marker: last["name"]))
  end
end
