# frozen_string_literal: true

module Admin::Participants
  class InductionRecordsController < Admin::BaseController
    include RetrieveProfile
    include FindInductionRecords

    def show
      @all_induction_records = all_induction_records

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
