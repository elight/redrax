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

    # When a new method is added, alias it and wrap it in a new method that 
    # responds to exceptions by adding the URL of the API docs to the exception
    # message.
    def method_added(method)
      return unless @current_doc_link

      @doc_urls ||= {}
      @doc_urls[method] = @current_doc_link

      # Prevent infinite recursion on define_method below
      @current_doc_link = nil

      alias_method "old_#{method}".to_sym, method

      define_method(method) do |*args|
        begin
          send("old_#{method}", *args)
        rescue Exception => e
          msg = e.message + "\n\nPlease refer to this URL for additional information on this API call:\n#{self.class.api_docs(method)}\n" 
          raise e, msg, e.backtrace
        end
      end
    end
  end
end
