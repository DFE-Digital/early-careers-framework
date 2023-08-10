# frozen_string_literal: true

module CodeHighlightHelper
  def highlight_as_json(obj)
    json = JSON.pretty_generate(obj)
    lexer = ::Rouge::Lexers::JSON.new
    highlight_with_lexer(lexer, json)
  end

  def highlight_as_plain_text(text)
    lexer = ::Rouge::Lexers::PlainText.new
    highlight_with_lexer(lexer, text)
  end

  def highlight_with_lexer(lexer, source)
    formatter = ::Rouge::Formatters::HTML.new
    tag.pre do
      code = sanitize(formatter.format(lexer.lex(source)), tags: %w[span], attributes: %w[class])
      tag.code(code)
    end
  end
end
