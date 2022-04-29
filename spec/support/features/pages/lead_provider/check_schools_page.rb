# frozen_string_literal: true

require_relative "../base"

module Pages
  class CheckSchoolsPage < ::Pages::Base
    set_url "/lead-providers/your-schools"
    set_primary_heading "Your schools"

    def confirm_more_schools
      click_on "Confirm more schools"

      # /lead-providers/report-schools/start
      raise "Not yet implemented"
    end

    def download_schools_for_2021
      click_on "Download schools for 2021"

      # /lead-providers/partnerships/active.csv
      raise "Not yet implemented"
    end

    def has_schools_recruited?(num_schools)
      expect(page).to have_content "#{num_schools} Schools recruited"
    end
  end
end
