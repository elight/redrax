module Redrax
  class File
    attr_accessor :name, :bytes, :content_type, :last_modified, :hash

    def self.from_hash(client, container, hash = {})
      new(client, container, *hash.values_at('name', 'bytes', 'content_type', 'last_modified', 'hash'))
    end

    def initialize(client, container, name, bytes = nil, content_type = nil, last_modified = nil, hash = nil)
      @name, @bytes, @content_type, @last_modified, @hash = 
        name, bytes, content_type, last_modified, hash
    end
  end
end
