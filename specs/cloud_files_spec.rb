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

    describe "#list" do
      it "get the user's list of containers, supplying a region for the req" do
        assert cf.containers.list(:region => :dfw).length > 0
      end

      it "returns an Array containing Container objects" do
        assert_instance_of Redrax::Container, cf.containers.list(:region => :dfw).first
      end

      it "gets the user's list of containers, using the configured region" do
        r1 = cf.containers.list(:region => :dfw)
        r2 = cf.containers.list
        refute_equal r1.length, r2.length
      end

      describe "#next_page" do
        it "paginates by returning a result set containing a call to #next_page" do
          r1 = cf.containers.list(:region => :dfw, :limit => 1) 
          assert_equal 1, r1.size
          assert_respond_to r1, :next_page
          r2 = r1.next_page
          assert_equal 1, r2.size
          refute_equal r1.last.name, r2.last.name
        end

        it "allows for the limit for the next page to be overridden" do
          r1 = cf.containers.list(:region => :dfw, :limit => 1) 
          r2 = r1.next_page(1_000)
          assert r2.size > 1
          assert r2.size < 1_000
        end
      end
    end

    describe "#container", :vcr do
      let(:files) { cf.containers["mikhailov"].files(:region => :dfw, :limit => 1) }

      it "gets the list of files within a specific container" do
        assert_instance_of Redrax::PaginatedFiles, files
        assert_equal files.size, 1
        assert_instance_of Redrax::File, files.first
      end

      it "paginates" do
        f1 = files.first
        f2 = files.next_page.first
        refute_equal f1.name, f2.name
      end
    end
  end

  describe Redrax::Container::Metadata, :vcr do
    let(:meta) { 
      params = {
        user: ENV['RAX_USERNAME'],
        api_key: ENV['RAX_API_KEY'],
        region: :dfw
      }
      cf = Redrax::CloudFiles.new.tap { |c|
        c.configure!(params).authenticate!
      }
      cf.containers["mikhailov"].metadata 
    }
        
    it "can add and remove metadata from a container" do
      meta.update(foo: :bar, baz: 42)
      m = meta.get
      assert_equal "bar", m["foo"]
      assert_equal "42", m["baz"]
      meta.delete(:foo, "baz")
      m = meta.get
      assert m.empty?
    end
  end
end

