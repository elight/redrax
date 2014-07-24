module Redrax
  class File
    attr_reader :name, :bytes, :content_type, :last_modified, :hash, :client, :container_name

    def self.from_hash(client, container_name, hash = {})
      new(client, container_name, *hash.values_at('name', 'bytes', 'content_type', 'last_modified', 'hash'))
    end

    def initialize(client, container_name, name, bytes = nil, content_type = nil, last_modified = nil, hash = nil)
      @client = client
      @container = container_name
      @name, @bytes, @content_type, @last_modified, @hash = 
        name, bytes, content_type, last_modified, hash
    end
  end
end
