module Redrax
  class PaginatedCollection < SimpleDelegator
    attr_reader :collection, :options
    
    def initialize(results, collection, options = {:limit => 10_000})
      super(results)
      @collection = collection
      @options    = options
    end

    def next_page(override_limit = nil)
      options[:limit] = override_limit if override_limit

      collection.send(collection_method, options.merge(marker: last.send(marker_field)))
    end

    def marker_field
      fail Exception, "Your PaginatedCollection subclass must provide a symbol representing the method to call on the paginated type to use as the API marker"
    end

    def collection_method
      fail Exception, "Your PaginatedCollection subclass must provide a symbol representing the method to call on the paginated type to get the next page of data"
    end
  end
end
