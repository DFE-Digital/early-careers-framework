# frozen_string_literal: true

module Schools
  module DashboardHelper
    def ect_count(school_cohorts)
      school_cohorts.sum { |sc| sc.current_induction_records.ects.count }
    end

    def ect_with_no_mentor_count(school_cohorts)
      school_cohorts.sum { |sc| sc.current_induction_records.ects.where(mentor_profile: nil).count }
    end

    def link_to_participant(participant_profile, school)
      govuk_link_to(participant_profile.full_name,
                    school_participant_path(id: participant_profile.id,
                                            school_id: school.slug),
                    no_visited_state: true,
                    class: "govuk-!-font-weight-regular")
    end

    def manage_ects_and_mentors?(school_cohorts)
      school_cohorts.any?(&:full_induction_programme?) || school_cohorts.any?(&:core_induction_programme?)
    end

    def mentor_count(school_cohorts)
      school_cohorts.sum { |sc| sc.current_induction_records.mentors.count }
    end

    def participants_count(school_cohorts)
      school_cohorts.sum { |sc| sc.current_induction_records.count }
    end

    def missing_mentor_html(participant_profile)
      tag.div(class: "app-summary-list__missing") do
        concat tag.div("No mentor assigned", class: "app-summary-list__missing-heading")
        concat govuk_link_to("Assign a mentor",
                             school_participant_edit_mentor_path(participant_id: participant_profile.id),
                             no_visited_state: true)
      end
    end
  end
end
