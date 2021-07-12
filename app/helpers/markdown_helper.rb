# frozen_string_literal: true

# source: https://github.com/DFE-Digital/apply-for-teacher-training/blob/main/app/helpers/markdown_helper.rb

module MarkdownHelper
  def markdown_to_html(markdown)
    GovukMarkdown.render(markdown.to_s).html_safe
  end
end
