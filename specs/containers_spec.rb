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
