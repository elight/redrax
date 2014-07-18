module Redrax
  class KeyPrefixer
    def call(hash, prefix)
      hash.each_with_object({}) { |kv, h|
        k, v = kv[0].to_s, kv[1].to_s
        new_key = 
          if k.downcase =~ /^#{prefix.downcase}/
            k
          else
            prefix + k
          end
        h[new_key] = v
      }
    end
  end
end
