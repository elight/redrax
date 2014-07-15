module Redrax
  # Decorator and Template Method (now that's a mouth full of pattern there) 
  # that acts as an external iterator across pages of data. Relies upon 
  # subclasses duck-typing `marker_field` and `collection_method` methods.
  # 
  # You want to subclass `PaginatedCollection` and not create and use instances
  # of it directly.
  class PaginatedCollection < SimpleDelegator
    attr_reader :collection, :options

    # @param results [Array] The data returned from the API call to paginate
    # @param collection [Object] Redrax Object that responds to the 
    #   `collected_method` and `marker_field` methods specified by the
    #   subclass of PaginatedCollection.
    # @param options [Hash] Optional arguments allowing:
    #   * :limit: The default size of each page
    def initialize(results, collection, options = {:limit => 10_000})
      super(results)
      @collection = collection
      @options    = options
    end

    # Retrieves the next page of data
    # @param limit [Integer] Page-specific limit size
    # @return [PaginatedCollection] Another `PaginatedCollection` containing
    #   the next page of data.
    def next_page(limit = nil)
      options[:limit] = limit if limit

      collection.send(
        collection_method, 
        options.merge(
          marker: last.send(marker_field)
        )
      )
    end

    # @return [Symbol] The name of the method to call on the collection to
    #   get the value of the marker for the next page of data.
    def marker_field
      fail Exception, "Your PaginatedCollection subclass must provide a symbol representing the method to call on the paginated type to use as the API marker"
    end

    # @return [Symbol] The name of the method to call on the collection to
    #   call the API requesting the next page of data.
    def collection_method
      fail Exception, "Your PaginatedCollection subclass must provide a symbol representing the method to call on the paginated type to get the next page of data"
    end
  end
end
