module Redrax
  class MetadataMarshaller
    def call(hash, prefix, options = {})
      hash.each_with_object({}) { |(key, v), h|
        key = key.to_s.downcase
        v   = v.to_s
        
        new_key = 
          if key =~ /^#{prefix.downcase}/
            key
          elsif options[:wrong] && found = Array(options[:wrong]).find { |w| key =~ /^#{w.downcase}/ }
            key.gsub(/#{found}/, prefix)
          else
            prefix + key
          end
        h[new_key] = v
      }
    end
  end
end
