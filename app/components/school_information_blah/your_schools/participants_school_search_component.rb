# frozen_string_literal: true

module SchoolInformation
  module YourSchools
    class ParticipantsSchoolSearchComponent < BaseComponent
      def initialize(schools:, selected_cohort:, school_search_form:)
        @schools = schools
        @selected_cohort = selected_cohort
        @school_search_form = school_search_form
      end
    end
  end
end
