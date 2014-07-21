require_relative 'spec_helper'

describe Redrax::Container, :vcr  do
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
  let(:container) {
    cf.containers["mikhailov"]
  }

  describe "#create and #delete" do
    let(:container_name) { "a_new_container" }
    let (:new_container) { cf.containers[container_name] }

    it "creates the container in Cloud Files" do
      resp = new_container.create

      containers = cf.containers.list
      assert containers.one? { |c| c.name == container_name }

      new_container.delete

      containers = cf.containers.list
      assert containers.none? { |c| c.name == container_name }      
    end

    it "can create the container with metadata" do
      resp = new_container.create(metadata: {foo: 42})
      meta = new_container.metadata.get
      new_container.delete

      assert_includes meta.keys, "foo"
      assert_equal "42", meta["foo"]
      
    end
  end

  describe "#files" do
    let(:files) { container.files }
      
    describe "#list" do 
      let(:list) { files.list(:limit => 1) }

      it "gets the list of files within a specific container" do
        assert_instance_of Redrax::PaginatedFiles, list
        assert_equal list.size, 1
        assert_instance_of Redrax::File, list.first
      end

      it "paginates list" do
        f1 = list.first
        f2 = list.next_page.first
        refute_equal f1.name, f2.name
      end
    end

    describe "#[]" do
      it "creates a new local File object" do
        file = files["foo"]
        assert_instance_of Redrax::File, file
        assert_equal "foo", file.name
      end
    end
  end

  describe "#metadata" do
    let(:meta) { container.metadata  }
        
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
