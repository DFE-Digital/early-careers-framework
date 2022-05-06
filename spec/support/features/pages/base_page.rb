# frozen_string_literal: true

module Sections
  class CookieConsentBanner < SitePrism::Section
    set_default_search_arguments ".govuk-cookie-banner", visible: false

    element :heading, "h2"
    element :success_message, :css, ".js-cookie-banner__success", visible: false

    load_validation do
      [has_heading?(text: "Cookies on Manage training for early career teachers"), "Cookie banner heading not found on page"]
    end

    def accept
      click_on "Accept analytics cookies"
    end

    def reject
      click_on "Reject analytics cookies"
    end

    def preferences_have_changed?
      success_message.visible?
      success_message.has_content? "You’ve set your cookie preferences."
    end

    def change_preferences
      success_message.visible?
      click_on "change your cookie settings"

      Pages::CookiePolicyPage.loaded
    end

    def hide_success_message
      click_on "Hide this message"
    end
  end
end

module Pages
  class BasePage < SitePrism::Page
    element :header, "h1"

    section :cookie_banner, ::Sections::CookieConsentBanner

    load_validation do
      [has_primary_heading?, "Primary heading \"#{primary_heading}\" not found on page"]
    end

    def self.loaded
      page_object = new
      is_displayed = page_object.displayed?
      is_loaded = page_object.loaded?

      if is_displayed && is_loaded
        page_object
      else
        raise "Expected #{page_object.url_matcher} to match #{page_object.current_path}"
      end
    end

    class << self
      attr_reader :primary_heading

      # Sets and returns the specific primary_heading that will be displayed for a page object
      #
      # @return [String]
      def set_primary_heading(primary_heading)
        @primary_heading = primary_heading
      end
    end

    def has_primary_heading?(_seconds = Capybara.default_max_wait_time)
      raise "primary_heading has not been set" if primary_heading.nil?

      unless header.has_content? primary_heading
        raise "expected \"#{header.text}\" to match \"#{primary_heading}\""
      end

      true
    end

    def go_back
      click_on "Back"
    end

    # helpers that can show what capybara sees

    def show_html
      puts page.html
    end

    def show_all_content
      puts page.text
    end

    def show_main_content
      puts page.find("main").text
    end

  private

    def primary_heading
      self.class.primary_heading
    end
  end
end
