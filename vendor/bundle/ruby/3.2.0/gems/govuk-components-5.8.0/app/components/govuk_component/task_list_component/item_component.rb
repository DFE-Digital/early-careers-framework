module GovukComponent
  class TaskListComponent::ItemComponent < GovukComponent::Base
    renders_one :status, ->(text: nil, cannot_start_yet: false, classes: [], html_attributes: {}, &block) do
      GovukComponent::TaskListComponent::StatusComponent.new(
        id_prefix: @id_prefix,
        count: @count,
        text:,
        cannot_start_yet:,
        classes:,
        html_attributes:,
        &block
      )
    end

    renders_one :title, ->(text: nil, href: nil, hint: nil, classes: [], html_attributes: {}, &block) do
      GovukComponent::TaskListComponent::TitleComponent.new(
        id_prefix: @id_prefix,
        count: @count,
        text:,
        href:,
        hint:,
        classes:,
        html_attributes:,
        &block
      )
    end

    attr_reader :raw_title, :hint, :href, :raw_status
    attr_writer :count

    def initialize(title: nil, href: nil, hint: nil, count: nil, id_prefix: nil, status: {}, classes: [], html_attributes: {})
      @raw_title  = title
      @href       = href
      @hint       = hint
      @raw_status = status
      @id_prefix  = id_prefix
      @count      = count

      super(classes:, html_attributes:)
    end

    def call
      if href.presence && status_content.cannot_start_yet
        fail(ArgumentError, "item cannot have a href with status where cannot_start_yet: true")
      end

      adjusted_html_attributes = if href.present? || title&.href.present?
                                   html_attributes_with_link_class
                                 else
                                   html_attributes
                                 end

      tag.li(safe_join([title_content, status_content].compact), **adjusted_html_attributes)
    end

  private

    def title_content
      title || with_title(**title_attributes)
    end

    def status_content
      status || with_status(**status_attributes)
    end

    def default_attributes
      { class: "#{brand}-task-list__item" }
    end

    def title_attributes
      { text: raw_title, href:, hint: }
    end

    def html_attributes_with_link_class
      html_attributes.tap { |h| h[:class].append("#{brand}-task-list__item--with-link") }
    end

    def status_attributes
      raw_status.is_a?(String) ? { text: raw_status } : raw_status
    end
  end
end
