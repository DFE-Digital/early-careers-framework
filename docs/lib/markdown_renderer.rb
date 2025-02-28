# frozen_string_literal: true

class MarkdownRenderer < GovukTechDocs::TechDocsHTMLRenderer
  class UnknownTagError < StandardError; end

  # Expects tags in the format: [#tag-1 #tag-2 #tag-3]
  INDIVIDUAL_TAG_PATTERN = /#([\w-]+)/
  TAGS_PATTEN = /\[(#{INDIVIDUAL_TAG_PATTERN}(?:\s+#{INDIVIDUAL_TAG_PATTERN})*)\]/

  TAG_MAPPINGS = {
    "breaking-change" => "red",
    "new-feature" => "green",
    "bug-fix" => "yellow",
    "new-field" => "turquoise",
    "data-update" => "blue",
    "contract-closure" => "orange",
    "new-course" => "pink",
    "production-release" => "purple",
    "sandbox-release" => "grey",
  }.freeze

  def preprocess(document)
    document.gsub(TAGS_PATTEN) do
      tags = Regexp.last_match(1).scan(INDIVIDUAL_TAG_PATTERN).flatten.map(&:downcase)
      sorted_tags = tags.sort_by { |tag| TAG_MAPPINGS.keys.index(tag) }
      %(<div class="tag-group">#{sorted_tags.map { |tag| render_tag(tag) }.join}</div>)
    end
  end

private

  def render_tag(tag)
    color = TAG_MAPPINGS[tag] or raise UnknownTagError, "Tag not recognised: #{tag}"
    text = tag.gsub("-", " ")

    "<strong class=\"govuk-tag govuk-tag--#{color}\">#{text}</strong>"
  end
end
