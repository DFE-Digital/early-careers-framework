# frozen_string_literal: true

module Api::V1::ECF
  class InductionRecordsQuery
    attr_reader :updated_since, :email

    def initialize(updated_since: nil, email: nil)
      @updated_since = updated_since
      @email         = email
    end

    def all
      induction_records = relevant_induction_records

      if updated_since.present?
        induction_records = induction_records.where("induction_records.updated_at > ?", updated_since)
      end

      if email.present?
        induction_records = induction_records.joins(:preferred_identity).where(preferred_identity: { email: })
      end

      induction_records
    end

    def relevant_induction_records
      InductionRecord
        .joins(
          <<-SQL,
            JOIN (#{induction_record_history.to_sql}) AS historical_induction_records
              ON historical_induction_records.id = induction_records.id AND historical_induction_records.chronology = 1
            JOIN participant_profiles ON induction_records.participant_profile_id = participant_profiles.id
          SQL
        )
        .merge(ParticipantProfile.ecf)
    end

    def induction_record_history
      InductionRecord.start_date_in_past
                     .select(
                       <<-SQL,
                         induction_records.id,
                         ROW_NUMBER() OVER (
                           PARTITION BY induction_records.participant_profile_id
                           ORDER BY induction_records.end_date ASC NULLS FIRST, induction_records.start_date ASC
                         ) AS chronology
                       SQL
                     )
                     .joins(:participant_profile)
    end
  end
end
