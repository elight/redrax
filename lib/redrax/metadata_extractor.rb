module Redrax
  class MetadataExtractor
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
