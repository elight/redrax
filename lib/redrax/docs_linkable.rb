module Redrax 
  # Extended classes can use this behavior to augment a class with metadata
  # linking to the wrapped API call.
  module DocsLinkable
    # adds a link to the API documentation for the next method defined
    # @param doc_link [String] a URL
    def docs(doc_link)
      @current_doc_link = doc_link
    end

    # method name to search for API docs
    # @param method [Symbol] the name of the method to search for
    # @return [String] a URL for more information on this API call
    def api_docs(method)
      @doc_urls ||= {}
      @doc_urls[method]
    end

    # Ruby callback to capture when a new method is defined
    def method_added(method)
      @doc_urls ||= {}
      @doc_urls[method] = @current_doc_link
    end
  end
end
