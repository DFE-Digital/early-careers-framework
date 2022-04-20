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

    def is_on_page?
      expect(current_path).to eq @url
      expect(page).to have_content @title
    end
  end
end
