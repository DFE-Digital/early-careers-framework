class GovukComponent::SummaryListComponent::ValueComponent < GovukComponent::Base
  attr_reader :text

  def initialize(text: nil, classes: [], html_attributes: {})
    super(classes:, html_attributes:)

    @text = text
  end

  def call
    tag.dd(value_content, **html_attributes)
  end

private

  def default_attributes
    { class: "#{brand}-summary-list__value" }
  end

  def value_content
    content || text || config.default_summary_list_value_text
  end
end
