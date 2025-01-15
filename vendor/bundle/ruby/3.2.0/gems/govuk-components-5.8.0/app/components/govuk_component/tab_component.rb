class GovukComponent::TabComponent < GovukComponent::Base
  using HTMLAttributesUtils

  renders_many :tabs, "Tab"

  attr_reader :title, :id

  def initialize(title: 'Contents', id: nil, classes: [], html_attributes: {})
    @title = title
    @id    = id

    super(classes:, html_attributes:)
  end

private

  def default_attributes
    { id:, class: "#{brand}-tabs", data: { module: "#{brand}-tabs" } }
  end

  class Tab < GovukComponent::Base
    attr_reader :label, :text, :id

    def initialize(label:, text: nil, id: nil, classes: [], html_attributes: {})
      @label = label
      @text  = h(text)
      @id    = id || label.parameterize

      super(classes:, html_attributes:)
    end

    def hidden_class(i = nil)
      return [] if i&.zero?

      ["#{brand}-tabs__panel--hidden"]
    end

    def li_classes(i = nil)
      class_names("#{brand}-tabs__list-item", "#{brand}-tabs__list-item--selected" => i&.zero?).split
    end

    def li_link
      link_to(label, "#" + id, class: "#{brand}-tabs__tab")
    end

    def default_attributes
      { id:, class: "#{brand}-tabs__panel" }
    end

    def combined_attributes(i)
      html_attributes.deep_merge_html_attributes({ class: hidden_class(i) }).deep_tidy_html_attributes
    end

    def call
      content || text || fail(ArgumentError, "no text or content")
    end
  end
end
