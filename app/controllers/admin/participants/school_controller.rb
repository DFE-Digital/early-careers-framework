# frozen_string_literal: true

module Admin::Participants
  class SchoolController < Admin::BaseController
    include RetrieveProfile
    include FindInductionRecords

    def show
      @latest_induction_record = latest_induction_record
      @school_cohort = @latest_induction_record&.school_cohort
      @lead_provider = @school_cohort&.lead_provider
      @school = @school_cohort&.school
      @mentees_by_school = ParticipantProfile::ECT
        .merge(InductionRecord.current)
        .joins(:induction_records)
        .where(induction_records: { mentor_profile_id: @participant_profile.id })
        .group_by(&:school)

      add_breadcrumb(@school.name, admin_school_participants_path(@school)) if @school.present?
    end
  end
end
