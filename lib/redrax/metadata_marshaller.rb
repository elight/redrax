module Redrax
  # Converts input into a format we can use to update Metadata against the API
  # @param [Hash] hash The hash of metadata we're going to marshal
  # @param [String] prefix The value we want to have prefix the key-value pairs
  # @param [Hash] options Accepts:
  #   * wrong: `String` or `Array` of `String`s of incorrect prefixes the caller
  #     may have supplied.  We can then identify and correct these for the
  #     caller.
  class MetadataMarshaller
    def call(hash, prefix, options = {})
      hash.each_with_object({}) { |(key, v), h|
        key = key.to_s.downcase
        v   = v.to_s
        
        new_key = 
          if key =~ /^#{prefix.downcase}/
            key
          elsif found = downcase_find(options[:wrong], key)
            key.gsub(/#{found}/, prefix)
          else
            prefix + key
          end
        h[new_key] = v
      }
    end

    private

    def downcase_find(src, term)
      if src 
        Array(src).find { |w| term =~ /^#{w.downcase}/ }
      end
    end
  end
end
