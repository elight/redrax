module Redrax
  class MetadataExtractor
    def call(pattern, headers)
      headers.each_with_object({}) { |header, h|
        k, v = header
        if k =~ /#{pattern}-?/i
          name = k.gsub(/^#{pattern}-?/i, "")
          h[name] = v
        end 
      }
    end
  end
end
