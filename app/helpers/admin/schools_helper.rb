# frozen_string_literal: true

module Admin
  module SchoolsHelper
    def link_to_2020_setup(school_id:, setup_done:)
      if setup_done
        text = admin_school_cohort2020_path(school_id:)
        url = "View 2020 cohort for NQT+1s"
      else
        text = start_schools_year_2020_path(school_id:)
        url = "Set up 2020 cohort for NQT+1s. Right click and copy link address for use in macros."
      end

      govuk_link_to(text, url)
    end
  end
end
