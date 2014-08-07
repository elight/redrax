class DocsMethodHandler < YARD::Handlers::Ruby::Base
  handles method_call(:docs)
  namespace_only

  def process
    $url = statement.parameters.first.jump(:tstring_content).source

    # This little bit of evil is due to YARD executing handlers in
    # the reverse order that they were registered. I want my 
    # handlers to go LAST! Otherwise, YARD, is wiping out my
    # changes!  And, yes, we only want to do this once.
    unless $reversed
      YARD::Handlers::Base.subclasses.reverse!
      $reversed = true
    end
  end
end

class APICallMethodHandler < YARD::Handlers::Ruby::Base
  handles :def
  namespace_only

  def process
    if $url
      method = statement.method_name(true).to_s
      object = YARD::CodeObjects::MethodObject.new(namespace, method)
      object.docstring.add_tag(
       YARD::Tags::Tag.new(:see, "<a href='#{$url}'>API documentation</a>")
     )
      $url = nil
    end
  end
end
