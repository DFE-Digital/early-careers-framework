# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class AdminSupportParticipantDetail < ::Pages::BasePage
    set_url "/admin/participants/{participant_id}/details"
    # this is a hack as the participants name is the page title
    set_primary_heading(/^(.*) - Details$/)

    def has_training_record_state?(validation_status)
      # TODO: get language from language files
      element_has_content? self, "Training record state #{validation_status}"
    end

    def has_full_name?(full_name)
      element_has_content? self, "Name#{full_name}Change name"
    end

    def has_email_address?(email_address)
      element_has_content? self, "Email address#{email_address}Change email"
    end

    def has_associated_email_address?(email_address)
      element_has_content? self, "Associated email addresses\n#{email_address}"
    end

    def has_trn?(trn)
      element_has_content? self, "TRN#{trn}"
    end

    def has_user_id?(user_id)
      element_has_content? self, "User ID#{user_id}"
    end

    def has_cohort?(start_year)
      element_has_content? self, "Cohort: #{start_year}"
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
  end
end
