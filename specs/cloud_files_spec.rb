require_relative 'spec_helper'

describe Redrax::CloudFiles do
  let(:cf) { Redrax::CloudFiles.new }

  let (:params) {
    {
      user: "foo",
      api_key: "bar"
    }
  }
  
  describe "#configure!" do
    it "delegates configuration to its Client" do
      cf.client = mock = Minitest::Mock.new
      cf.client.expect(:configure!, mock, [params])

      cf.configure!(params)

      mock.verify
    end
  end

  describe "#authenticate!" do
    it "delegates authentication to its Client" do
      cf.client = mock = Minitest::Mock.new
      cf.client.expect(:authenticate!, mock)
      
      cf.authenticate!

      mock.verify
    end
  end

  
end
