# frozen_string_literal: true

module Admin::Participants
  class ValidateDetailsController < Admin::BaseController
    include RetrieveProfile

    before_action :check_can_update_validation_data

    def new
      @preview_data = Admin::Participants::ValidateDetails.preview(@participant_profile)
    end

    def create
      validation_response = Admin::Participants::ValidateDetails.call(@participant_profile)

      generate_status_message(validation_response)
      redirect_to validation_page
    end

  private

    def generate_status_message(validation_result)
      if validation_result.blank?
        set_important_message(content: "No match was found for these details")
      else
        set_success_message(content: "Details matched and eligibility determined")
      end
    end

    def validation_page
      admin_participant_validation_data_path(@participant_profile)
    end

    def check_can_update_validation_data
      return if policy(@participant_profile).update_validation_data?

      set_important_message(content: "You cannot update the validation data for this participant")
      redirect_to validation_page
    end
  end
end
