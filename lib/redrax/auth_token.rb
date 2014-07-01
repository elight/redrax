module Redrax
  class AuthToken
    def initialize(hash)
      @token = hash.dup.freeze
    end

    def id
      @token['id']
    end
  end
end
