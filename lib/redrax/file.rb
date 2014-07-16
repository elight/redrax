module Redrax
  class File
    attr_accessor :name, :bytes, :content_type, :last_modified, :hash

    def self.from_hash(client, hash = {})
      new(*hash.values_at('name', 'bytes', 'content_type', 'last_modified', 'hash'))
    end

    def initialize(name, bytes, content_type, last_modified, hash)
      @name, @bytes, @content_type, @last_modified, @hash = 
        name, bytes, content_type, last_modified, hash
    end
  end
end
