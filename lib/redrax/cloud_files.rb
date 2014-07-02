require 'forwardable'

module Redrax
  class CloudFiles
    extend Forwardable

    def_delegators :@client, :configure!, :authenticate!

    def initialize(client = Redrax::Client.new)
      @client = client
    end
  end
end
