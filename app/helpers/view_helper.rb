module ViewHelper
  def govuk_link_to(body, url, html_options = {}, &_block)
    html_options[:class] = prepend_css_class("govuk-link", html_options[:class])

    return link_to(url, html_options) { yield } if block_given?

    link_to(body, url, html_options)
  end

  def govuk_back_link_to(url = :back, body = "Back")
    classes = "govuk-back-link"

    if url == :back
      url = controller.request.env["HTTP_REFERER"] || "javascript:history.back()"
      classes += " app-back-link--fallback"
    end

    if url == "javascript:history.back()"
      classes += " app-back-link--no-js"
    end

    link_to(body, url, class: classes)
  end

  def govuk_button_link_to(body, url, html_options = {}, &_block)
    html_options = {
      class: prepend_css_class("govuk-button", html_options[:class]),
      role: "button",
      data: { module: "govuk-button" },
      draggable: false,
    }.merge(html_options)

    return link_to(url, html_options) { yield } if block_given?

    link_to(body, url, html_options)
  end

private

  def prepend_css_class(css_class, current_class)
    if current_class
      current_class.prepend("#{css_class} ")
    else
      css_class
    end
  end
end
