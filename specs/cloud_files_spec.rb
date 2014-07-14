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

  describe "requests", :vcr do
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

    describe "#list_containers" do
      it "get the user's list of containers, supplying a region for the req" do
        assert cf.containers.list_containers(:region => :dfw).length > 0
      end

      it "gets the user's list of containers, using the configured region" do
        r1 = cf.containers.list_containers(:region => :dfw)
        r2 = cf.containers.list_containers
        refute_equal r1.length, r2.length
      end
    end

    describe "#container", :vcr do
      it "gets the list of files within a specific container" do
        file_list = cf.containers.container("my-test-dir", :region => :dfw)
        assert_instance_of Array, file_list
        assert file_list.size > 0
      end
    end
  end
end
