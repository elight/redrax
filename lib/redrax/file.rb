module Redrax
  class File
    extend Redrax::DocsLinkable

    attr_reader :client, :container, :region, :name, :bytes, :content_type, :last_modified, :hash

    def self.from_hash(client, container, region, hash = {})
      new(client, container, region, *hash.values_at('name', 'bytes', 'content_type', 'last_modified', 'hash'))
    end

    def initialize(client, container, region, name, bytes, content_type, last_modified, hash)
      @client = client
      @container = container
      @region = region
      @name, @bytes, @content_type, @last_modified, @hash = 
        name, bytes, content_type, last_modified, hash
    end
    
    docs "http://docs.rackspace.com/files/api/v1/cf-devguide/content/GET_getobjectdata_v1__account___container___object__objectServicesOperations_d1e000.html"
    def get(options = {})
      options = options.dup
      options[:region] ||= region || container.region || client.region
      
      client.request(
        method:   :get,
        path:     "#{container.name}/#{name}",
        params:   options.merge(do_not_parse: true),
        expected: [200, 206]
      )
    end
  end
end
