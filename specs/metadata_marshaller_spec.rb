require_relative 'spec_helper'

describe Redrax::MetadataMarshaller do
  let (:pre) { Redrax::MetadataMarshaller.new }

  it "noops keys that already have the desired prefix" do
    actual   = pre.call({"a-a" => 42}, "a-")
    expected = {"a-a" => "42"}

    assert_equal expected, actual
  end

  it "adds the prefix to the beginnings of keys missing the prefix" do
    actual   = pre.call({"a" => 42}, "a-")
    expected = {"a-a" => "42"}

    assert_equal expected, actual
  end
end
