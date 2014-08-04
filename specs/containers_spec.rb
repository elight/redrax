require_relative 'spec_helper'

describe Redrax::Containers, :vcr  do
  let(:cf) { 
    Redrax::CloudFiles.new.tap { |c|
      c.configure!(
        user: ENV['RAX_USERNAME'],
        api_key: ENV['RAX_API_KEY'],
        region: :dfw
      )
      c.authenticate!
    }
  }
  let(:containers) { cf.containers }

  it "can add and remove metadata from a container" do
    container_name = "mikhailov"
    containers.update_metadata(container_name, foo: :bar, baz: 42)
    m = containers.get_metadata(container_name)
    assert_equal "bar", m["foo"]
    assert_equal "42", m["baz"]
    containers.delete_metadata(container_name, :foo, "baz")
    m = containers.get_metadata(container_name)
    assert m.empty?
  end

  describe "#list" do 
    it "returns a list of contains in Cloud Files for this account" do
      list = containers.list
      assert_instance_of Redrax::Containers::PaginatedContainers, list
      assert !list.empty?
      assert_instance_of Redrax::Container, list.first
    end

    it "get the user's list of containers, supplying a region for the req" do
      assert containers.list(:region => :dfw).length > 0
    end

    it "returns an Array containing Container objects" do
      assert_instance_of Redrax::Container, containers.list(:region => :dfw).first
    end

    it "gets the user's list of containers, using the configured region" do
      r1 = containers.list(:region => :iad)
      r2 = containers.list
      refute_equal r1.length, r2.length
    end

    describe "#next_page" do
      it "paginates by returning a result set containing a call to #next_page" do
        r1 = containers.list(:region => :dfw, :limit => 1) 
        assert_equal 1, r1.size
        assert_respond_to r1, :next_page
        r2 = r1.next_page
        assert_equal 1, r2.size
        refute_equal r1.last.name, r2.last.name
      end

      it "allows for the limit for the next page to be overridden" do
        r1 = containers.list(:region => :dfw, :limit => 1) 
        r2 = r1.next_page(1_000)
        assert r2.size > 1
        assert r2.size < 1_000
      end
    end
  end

  describe "#create and #delete" do
    let(:container_name) { "a_new_container" }
    let (:new_container) { cf.containers[container_name] }

    it "creates the container in Cloud Files" do
      containers.create(container_name)

      assert containers.list.one? { |c| c.name == container_name }

      containers.delete(container_name)

      assert containers.list.none? { |c| c.name == container_name }
    end

    it "can create the container with metadata" do
      containers.create(container_name, foo: 42)
      meta = containers.get_metadata(container_name)
      containers.delete(container_name)

      assert_includes meta.keys, "foo"
      assert_equal "42", meta["foo"]
    end
  end
end
