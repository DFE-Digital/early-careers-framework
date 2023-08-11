# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class AdminSupportParticipantTraining < ::Pages::BasePage
    set_url "/admin/participants/{participant_id}/school"
    # this is a hack as the participants name is the page title
    set_primary_heading(/^(.*) - Training details$/)

    def has_cohort?(start_year)
      element_has_content? self, "Cohort: #{start_year}"
    end

    def has_school_name?(school_name)
      element_has_content? self, "School name#{school_name}"
    end

    def has_school_urn?(school_urn)
      element_has_content? self, "School URN#{school_urn}"
    end

    def has_school_record_state?(school_record_state)
      # TODO: get language from language files
      element_has_content? self, "School record state#{school_record_state}"
    end

    def has_lead_provider?(lead_provider_name)
      element_has_content? self, "Lead provider#{lead_provider_name}"
    end

    def has_school_transfer?(school_name)
      # School transfers
      # | School name | Induction Programme | Start Date | End Date |
      # | {school_name} | Full induction programme | 1 September 2021 | 4 September 2021 |
    end

    def open_details_tab
      click_on "Details"

      Pages::AdminSupportParticipantDetail.loaded
    end

    def open_training_tab
      click_on "Training"

      Pages::AdminSupportParticipantTraining.loaded
    end

    def open_statuses_tab
      click_on "Statuses"
    end
  end
end
