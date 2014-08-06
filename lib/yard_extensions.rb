class DocsMethodHandler < YARD::Handlers::Ruby::Base
  handles method_call(:docs)
  namespace_only

  def process
    $url = statement.parameters.first.jump(:tstring_content).source

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
