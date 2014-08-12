module Redrax
  class MetadataExtractor
    # Extracts and returns (only) Metadata from HTTP response headers
    # @param [String] pattern The prefix of the names of the Metadata fields 
    #  in the HTTP response headers, e.g., x-object-meta for Cloud Files objects
    # @param [Hash] headers The HTTP headers provided by the HTTP response
    # @return [Hash] the Metadata extracted from the HTTP response.  The keys
    #   will *not* contain the `pattern` prefix, e.g., "x-object-meta-foo"
    #   would simply have the key "foo".
    def call(pattern, headers)
      headers.each_with_object({}) { |(k, v), h|
        if k =~ /#{pattern}-?/i
          name = k.gsub(/^#{pattern}-?/i, "")
          h[name] = v
        end 
      }
    end
  end
end
