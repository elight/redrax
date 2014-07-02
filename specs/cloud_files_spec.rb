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
        api_key: ENV['RAX_API_KEY']
      }
    }

    it "retrieves the user's list of containers" do
      resp = cf.list_containers(:region => :dfw)
      require 'pry'
      binding.pry
    end
  end
end
