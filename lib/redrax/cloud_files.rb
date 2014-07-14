require 'forwardable'

module Redrax
  class CloudFiles
    extend DocsLinkable
    extend Forwardable

    attr_reader :client, :containers

    def_delegators :@client, :configure!, :authenticate!

    def initialize(client = Redrax::Client.new('cloudFiles'))
      @client = client
      
      @containers = Containers.new(@client)
    end
  end
end
