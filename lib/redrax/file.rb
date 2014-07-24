module Redrax
  class File
    attr_accessor :name, :bytes, :content_type, :last_modified, :hash, :client, :container_name, :body, :metadata

    def self.from_hash(hash = {})
      new(*hash.values_at('name', 'bytes', 'content_type', 'last_modified', 'hash'))
    end

    def self.from_response(name, response)
      new(name) do |f|
        bytes, f.content_type, f.last_modified = 
          response.headers.values_at('content-length', 'content-type', 'last-modified')
        f.bytes = bytes.to_i
        f.body = response.body
        f.metadata = MetadataExtractor.new.call("x-object-meta", response.headers)
      end
    end

    def initialize(name, bytes = nil, content_type = nil, last_modified = nil, hash = nil, &block)
      @metadata == {}
      @name, @bytes, @content_type, @last_modified, @hash = 
        name, bytes, content_type, last_modified, hash
      yield self if block_given?
    end
  end
end
