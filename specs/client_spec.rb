require_relative 'spec_helper'

describe Redrax::Client do
  let(:client) { Redrax::Client.new }
  let(:user) { "foo" }
  let(:api_key) { "bar" }
  let(:config) {
    {
      user:    user,
      api_key: api_key,
      region:  :iad
    }
  }

  describe "#configure!" do

    before do 
      client.configure!(config)
    end
      

    it "saves a copy of the supplied config" do
      assert_equal client.config, config
      refute_equal client.config.object_id, config.object_id
    end

    it "freezes its copy of the config" do
      assert client.config.frozen?
    end
  end

  describe "authenticate!", :vcr do
    it "raises an error when failing to authenticate" do
      client.configure!(config)

      assert_raises(Redrax::UnauthorizedException) do
        client.authenticate!
      end
    end

    it "returns itself when successful" do
      client.configure!(
        user:    ENV['RAX_USERNAME'],
        api_key: ENV['RAX_API_KEY']
      )
      assert_equal client.authenticate!, client
    end
  end
end
