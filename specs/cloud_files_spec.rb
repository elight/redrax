require_relative 'spec_helper'

describe Redrax::CloudFiles do
  describe "dependencies" do
    let(:mock_client) { Minitest::Mock.new }
    let(:cf)          { Redrax::CloudFiles.new(mock_client) }

    let (:params) {
      {
        user: "foo",
        api_key: "bar"
      }
    }
    
    describe "#configure!" do
      it "delegates configuration to its Client" do
        mock_client.expect(:configure!, mock_client, [params])

        cf.configure!(params)

        mock_client.verify
      end
    end

    describe "#authenticate!" do
      it "delegates authentication to its Client" do
        mock_client.expect(:authenticate!, mock_client)
        
        cf.authenticate!

        mock_client.verify
      end
    end
  end

  describe "#list_containers", :vcr do
    let(:cf)      { 
      Redrax::CloudFiles.new.tap { |c|
        c.configure!(params).authenticate!
      }
    }
    let (:params) {
      {
        user: ENV['RAX_USERNAME'],
        api_key: ENV['RAX_API_KEY'],
        region: :iad
      }
    }

    it "get the user's list of containers, supplying a region for the req" do
      assert cf.list_containers(:region => :dfw).length > 0
    end

    it "gets the user's list of containers, using the configured region" do
      r1 = cf.list_containers(:region => :dfw)
      r2 = cf.list_containers
      refute_equal r1.length, r2.length
    end
  end
end
