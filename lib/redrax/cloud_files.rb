require 'forwardable'

module Redrax
  class CloudFiles
    extend Forwardable

    attr_accessor :client

    def_delegators :@client, :configure!, :authenticate!
  end
end
