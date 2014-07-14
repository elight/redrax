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

    describe "#all" do
      it "get the user's list of containers, supplying a region for the req" do
        assert cf.containers.all(:region => :dfw).length > 0
      end

      it "gets the user's list of containers, using the configured region" do
        r1 = cf.containers.all(:region => :dfw)
        r2 = cf.containers.all
        refute_equal r1.length, r2.length
      end

      it "handles pagination by returning a result set containing a call to the next page" do
        r1 = cf.containers.all(:region => :dfw, :limit => 1) 
        assert_equal 1, r1.size
        assert_respond_to r1, :next_page
        r2 = r1.next_page
        assert_equal 1, r2.size
        refute_equal r1.last["name"], r2.last["name"]
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
