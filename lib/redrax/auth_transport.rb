require 'delegate'

module Redrax 
  class AuthTransport < SimpleDelegator
    US_SERVER = 'https://identity.api.rackspacecloud.com'
    
    def initialize
      __setobj__(Faraday.new(:url => US_SERVER))
    end 
  end
end
