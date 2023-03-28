# frozen_string_literal: true

module Admin::Participants
  class HistoryController < Admin::BaseController
    include RetrieveProfile
    include FindInductionRecords

    def show
      @relevant_induction_record = relevant_induction_record
      @historical_induction_records = historical_induction_records

      add_breadcrumb(
        school.name,
        admin_school_participants_path(school),
      )
    end

  private

    def school
      @school ||= @participant_profile.school
    end
  end
end
