# frozen_string_literal: true

module Pages
  class Base
    include Capybara::DSL
    include RSpec::Matchers

    attr_internal :url,
                  :title

    def load
      visit @url
    end

    def is_current_page?
      expect(current_path).to eq @url

      within(:css, "h1") do
        has_content? @title
      end
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
  end
end
