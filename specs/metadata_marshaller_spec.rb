require_relative 'spec_helper'

describe Redrax::MetadataMarshaller do
  let (:pre) { Redrax::MetadataMarshaller.new }

  it "downcases keys that already have the desired prefix" do
    input    = {"X-Container-Meta-a" => 42}
    expected = {"x-container-meta-a" => "42"}

    actual   = pre.call(input, "x-container-meta-")

    assert_equal expected, actual
  end

  it "adds the prefix to the beginnings of keys missing the prefix" do
    input    = {"a" => 42}
    expected = {"x-container-meta-a" => "42"}

    actual   = pre.call(input, "x-container-meta-")

    assert_equal expected, actual
  end

  it "converts known wrong prefixes to the right one" do
    input = {
      "X-Remove-Container-Meta-a" => 42,
      "c-b"                       => 43,
      "x-container-meta-c"        => "control"
    }
    expected = {
      "x-container-meta-a" => "42",
      "x-container-meta-b" => "43",
      "x-container-meta-c" => "control"
    }

    actual   = pre.call(input, "x-container-meta-", :wrong => ["x-remove-container-meta-", "c-"])

    assert_equal expected, actual
  end

  it "accepts singular wrong prefixes too" do
    input = {
      "X-Remove-Container-Meta-a" => 42,
      "x-container-meta-c"        => "control"
    }
    expected = {
      "x-container-meta-a" => "42",
      "x-container-meta-c" => "control"
    }

    actual   = pre.call(input, "x-container-meta-", :wrong => "x-remove-container-meta-")

    assert_equal expected, actual
  end

end
