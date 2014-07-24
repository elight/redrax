require_relative 'spec_helper'

describe Redrax::Files, :vcr do
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
  let(:container_name) { "mikhailov" }
  let(:file_name) { "test_file" }
  let(:files) { cf.files }
    
  describe "#list" do 
    let(:list) { files.list(container_name, :limit => 1) }

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

  describe "CRUD" do
    it "can create w/ metadata, get, and delete a file in Cloud Files" do
      files.create(
        container_name, 
        file_name,
        "Ohai",
        :metadata => { "foo" => 42 },
        :headers => { "content-type" => "text/plain" }
      )

      file = files.get(container_name, file_name)

      assert_equal "\"Ohai\"", file.body
      assert_equal 6, file.bytes
      assert_equal "text/plain", file.content_type
      assert_equal 1, file.metadata.size
      assert_equal "42", file.metadata["foo"]

      files.delete(container_name, file_name)

      assert_raises(Exception) do
        files.get(container_name, file_name)
      end
    end
  end
end
