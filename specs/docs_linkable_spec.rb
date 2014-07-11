require_relative 'spec_helper'

class FakeAPIBinding
  extend Redrax::DocsLinkable

  docs "http://foo.com"
  def foo; end

  docs "http://bar.com"
  def bar; end

  docs "http://this.raised.com"
  def this_raises
    fail ArgumentError, "Look, I came here for an argument."
  end

  def no_url_here_please
    fail ArgumentError, "Oh, oh, I'm sorry! This is abuse!"
  end
end
  

describe Redrax::DocsLinkable do
  it "provides a DSL for documentation links to augment a method" do
    assert_equal("http://foo.com", FakeAPIBinding.api_docs(:foo))
    assert_equal("http://bar.com", FakeAPIBinding.api_docs(:bar))
  end

  it "adds the String provided to the method's docs call to Exceptions from the method" do
    begin
      FakeAPIBinding.new.this_raises
    rescue ArgumentError => e
      assert e.message =~ /this\.raised\.com/, "Exception message is missing doc URL"
    end
  end

  it "treats methods not preceded by a #docs call normally" do
    begin
      FakeAPIBinding.new.no_url_here_please
    rescue ArgumentError => e
      assert e.message !~ /\.com/, "Exception should not have a URL"
    end    
  end
end
