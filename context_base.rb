require 'erb'

class ContextBase
  def render(template)
    ERB.new(template).result(binding)
  end
end
