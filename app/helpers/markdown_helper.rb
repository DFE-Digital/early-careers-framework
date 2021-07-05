# frozen_string_literal: true

module MarkdownHelper
  def markdown_to_html(markdown)
    GovukMarkdown.render(markdown.to_s).html_safe
  end
end
