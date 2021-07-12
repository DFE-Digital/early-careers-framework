# frozen_string_literal: true

class MarkdownHandler
  def self.erb
    @erb ||= ActionView::Template.registered_template_handler(:erb)
  end

  def self.call(template, source = template.source)
    compiled_template = GovukMarkdown.render(source)
    erb.call(template, compiled_template)
  end
end

ActionView::Template.register_template_handler :md, MarkdownHandler
ActionView::Template.register_template_handler :markdown, MarkdownHandler
