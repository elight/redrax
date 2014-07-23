require_relative 'spec_helper'

describe Redrax::File, :vcr do
  let(:container) { 
    cf = Redrax::CloudFiles.new
    cf.configure!(
      user: ENV['RAX_USERNAME'],
      api_key: ENV['RAX_API_KEY'],
      region: :iad
    )
    cf.authenticate!
    cf.containers["test_container"]
  }
  let(:file) {
    container.files["new_file"]
  }

  before do
    container.create
  end

  after do
    file.delete
    container.delete
  end

  it "can create w/ metadata and delete a file in Cloud Files" do
    container.files["new_file"].create(
      "Ohai",
      :metadata => { "foo" => 42 },
      :headers => { "content-type" => "text/plain" }
    )

    file = container.files.list.first
    body = file.get

    assert_equal "\"Ohai\"", body
  end
end
