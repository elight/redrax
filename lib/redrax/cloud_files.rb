require 'forwardable'

module Redrax
  class CloudFiles
    extend DocsLinkable
    extend Forwardable

    attr_reader :client, :containers, :files

    def_delegators :@client, :configure!, :authenticate!

    def initialize(client = Redrax::Client.new('cloudFiles'))
      @client = client
      
      @containers = Containers.new(@client)
      @files = Files.new(@client)
    end
  end
end
