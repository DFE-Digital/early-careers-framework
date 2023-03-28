# frozen_string_literal: true

module Admin::Participants
  class DetailsController < Admin::BaseController
    include RetrieveProfile
    include FindInductionRecords

    def show
      @relevant_induction_record = relevant_induction_record
      @user = @participant_profile.user

      add_breadcrumb(school.name, admin_school_participants_path(school)) if school.present?
    end

  private

    def school
      @school ||= @participant_profile.school
    end
  end
end
