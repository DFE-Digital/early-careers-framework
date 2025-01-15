class GovukComponent::BreadcrumbsComponent < GovukComponent::Base
  attr_reader :breadcrumbs, :hide_in_print, :collapse_on_mobile, :inverse

  def initialize(breadcrumbs:,
                 hide_in_print: config.default_breadcrumbs_hide_in_print,
                 collapse_on_mobile: config.default_breadcrumbs_collapse_on_mobile,
                 inverse: false,
                 classes: [],
                 html_attributes: {})

    @breadcrumbs        = build_list(breadcrumbs)
    @hide_in_print      = hide_in_print
    @collapse_on_mobile = collapse_on_mobile
    @inverse            = inverse

    super(classes:, html_attributes:)
  end

private

  def default_attributes
    {
      class: class_names(
        "#{brand}-breadcrumbs",
        "#{brand}-!-display-none-print" => hide_in_print,
        "#{brand}-breadcrumbs--collapse-on-mobile" => collapse_on_mobile,
        "#{brand}-breadcrumbs--inverse" => inverse
      ).split
    }
  end

  def build_list(breadcrumbs)
    case breadcrumbs
    when Array
      breadcrumbs.map { |item| build_list_item(item) }
    when Hash
      breadcrumbs.map { |text, link| build_list_item(text, link) }
    else
      fail(ArgumentError, "breadcrumbs must be an array or hash")
    end
  end

  def build_list_item(text, link = nil)
    if link.present?
      list_item { link_to(text, link, class: "#{brand}-breadcrumbs__link") }
    else
      list_item(aria: { current: "page" }) { text.to_s }
    end
  end

  def list_item(html_attributes = {}, &block)
    tag.li(class: "#{brand}-breadcrumbs__list-item", **html_attributes, &block)
  end
end
