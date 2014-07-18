require_relative 'spec_helper'

describe Redrax::Container, :vcr  do
  let(:container) { 
    cf = Redrax::CloudFiles.new
    cf.configure!(
      user: ENV['RAX_USERNAME'],
      api_key: ENV['RAX_API_KEY'],
      region: :dfw
    )
    cf.authenticate!
    cf.containers["mikhailov"]
  }

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
