require_relative 'spec_helper'

class FakeAPIBinding
  extend Redrax::DocsLinkable

  docs "http://foo.com"
  def foo; end

  docs "http://bar.com"
  def bar; end
end
  

describe Redrax::DocsLinkable do
  it "provides a DSL for documentation links to augment a method" do
    assert_equal("http://foo.com", FakeAPIBinding.api_docs(:foo))
    assert_equal("http://bar.com", FakeAPIBinding.api_docs(:bar))
  end
end
