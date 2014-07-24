module Redrax
  # Decorator and Template Method (now that's a mouth full of pattern there) 
  # that acts as an external iterator across pages of data. Relies upon 
  # subclasses duck-typing `marker_field` and `collection_method` methods.
  # 
  # You want to subclass `PaginatedCollection` and not create and use instances
  # of it directly.
  class PaginatedCollection < SimpleDelegator
    attr_reader :collection, :options, :scoping

    # @param results [Array] The data returned from the API call to paginate
    # @param collection [Object] Redrax Object that responds to the 
    #   `collected_method` and `marker_field` methods specified by the
    #   subclass of PaginatedCollection.
    # @param scoping [String] Name of the entity this collection is nested under
    # @param options [Hash] Optional arguments allowing:
    #   * :limit: The default size of each page
    # NOTE: Currently supports a scoping depth of 1. May augment `scoping` to
    #  also accept an Array in the future to allow for arbitrary nesting.
    def initialize(results, collection, scoping = nil, options = {:limit => 10_000})
      super(results)
      @collection = collection
      @scoping    = scoping
      @options    = options
    end

    # Retrieves the next page of data
    # @param limit [Integer] Page-specific limit size
    # @return [PaginatedCollection] Another `PaginatedCollection` containing
    #   the next page of data.
    def next_page(limit = nil)
      @options[:limit]  = limit if limit
      @options[:marker] = last.send(self.class.field_name)

      args = []
      args << self.class.collection_name
      args << scoping if scoping
      args << options

      collection.send(*args)
    end

    # @return [Symbol] The name of the method to call on the collection to
    #   get the value of the marker for the next page of data.
    def self.marker_field(field_name)
      @field_name = field_name
    end

    def self.field_name
      @field_name
    end

    # @return [Symbol] The name of the method to call on the collection to
    #   call the API requesting the next page of data.
    def self.collection_method(collection_name)
      @collection_name = collection_name
    end

    def self.collection_name
      @collection_name
    end
  end
end
