require_relative 'spec_helper'

describe Redrax::PathValidation do
  let(:validator) { Object.new.extend(Redrax::PathValidation) }

  describe "#identify_errors" do
    it "identifies blank values as errors" do
      refute_empty validator.identify_errors("")
    end

    it "identifies nil values as errors" do
      refute_empty validator.identify_errors(nil)
    end
  end

  describe "#validate_path_elements" do
    it "identifies blank values as errors" do
      assert_raises(ArgumentError) do
        validator.validate_path_elements("")
      end
    end

    it "identifies nil values as errors" do
      assert_raises(ArgumentError) do
        validator.validate_path_elements(nil)
      end
    end
  end
end
