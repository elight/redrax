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

  describe "authenticate!" do
    it "raises an error when failing to authenticate" do
      assert_raises(Redrax::UnauthorizedException) do
        client.configure!(config).authenticate!
      end
    end
  end
end
