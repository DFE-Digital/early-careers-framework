# frozen_string_literal: true

module Pages
  class Base < SitePrism::Page
    element :header, "h1"

    def self.loaded
      page_object = new
      if page_object.displayed?
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

    def has_primary_heading?(seconds = Capybara.default_max_wait_time)
      return unless displayed?(seconds)

      raise "primary_heading has not been set" if primary_heading.nil?

      unless header.has_content? primary_heading
        raise "expected \"#{header.text}\" to match \"#{primary_heading}\""
      end

      true
    end

    def go_back
      click_on "Back"
    end

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
