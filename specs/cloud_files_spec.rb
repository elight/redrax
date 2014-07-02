require_relative 'spec_helper'

describe Redrax::CloudFiles do
  let(:client) { Minitest::Mock.new }
  let(:cf)     { Redrax::CloudFiles.new(client) }

  let (:params) {
    {
      user: "foo",
      api_key: "bar"
    }
  }
  
  describe "#configure!" do
    it "delegates configuration to its Client" do
      client.expect(:configure!, client, [params])

      cf.configure!(params)

      client.verify
    end
  end

  describe "#authenticate!" do
    it "delegates authentication to its Client" do
      client.expect(:authenticate!, client)
      
      cf.authenticate!

      client.verify
    end
  end

  
end
