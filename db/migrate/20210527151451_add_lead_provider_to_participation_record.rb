# frozen_string_literal: true

class AddLeadProviderToParticipationRecord < ActiveRecord::Migration[6.1]
  def change
    add_reference :participation_records, :lead_provider, null: true, index: true, foreign_key: true, type: :uuid
    ParticipationRecord.all.each do |participant_record|
      ect_profile = participant_record.early_career_teacher_profile
      school_cohort = SchoolCohort.find_by(school: ect_profile.school, cohort: ect_profile.cohort)
      participant_record.update!(lead_provider_id: school_cohort&.lead_provider&.id)
    end
    change_column_null :participation_records, :lead_provider_id, false, "gen_random_uuid()"
  end
end
