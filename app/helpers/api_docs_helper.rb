# frozen_string_literal: true

module ApiDocsHelper
  def json_code_sample(code)
    source = JSON.pretty_generate(code)
    formatter = Rouge::Formatters::HTML.new
    lexer = Rouge::Lexers::JSON.new

    tag.pre class: "app-json-code-sample" do
      tag.code do
        formatter.format(lexer.lex(source)).html_safe
      end
    end
  end

  def csv_sample(example)
    tag.pre class: "app-csv-code-sample" do
      tag.code do
        example
      end
    end
  end
end
