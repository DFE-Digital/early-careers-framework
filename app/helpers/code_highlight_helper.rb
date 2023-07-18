# frozen_string_literal: true

module CodeHighlightHelper
  def highlight_as_json(obj)
    json = JSON.pretty_generate(obj)
    formatter = ::Rouge::Formatters::HTML.new
    lexer = ::Rouge::Lexers::JSON.new
    tag.pre(class: "app-json-code-sampe") do
      code = sanitize(formatter.format(lexer.lex(json)), tags: %w[span], attributes: %w[class])
      tag.code(code)
    end
  end
end
