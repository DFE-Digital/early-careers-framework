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
        # this has to check all updatable entities
        induction_records = induction_records
                              .joins(participant_profile: [:user])
                              .where("induction_records.updated_at > ? OR participant_profiles.updated_at > ? OR users.updated_at > ?", updated_since, updated_since, updated_since)
      end

      if email.present?
        # this has to return just one record
        induction_records = induction_records.joins(:preferred_identity).where(preferred_identity: { email: })
      end

      induction_records
    end

    def relevant_induction_records
      InductionRecord.where(id: induction_record_history)
    end

    def induction_record_history
      # we can't use `InductionRecord.current` here, because we need to include records that finished in the past if there is no current one
      # we can't use `InductionRecord.latest` here because the latest record might not be what they are doing right now
      #
      # we need to find the oldest `participant_profile` for the user otherwise we risk unwanted changes to their access
      # we need to prioritise `end_date` with `null` first because we need to find the record describing what they are doing right now over what they will eventually do after a transfer
      # we need to order by `start_date` second in case two records have the same `end_date` such as after modifying a transfer to add a mentor
      #
      # we can group by "participant_profiles"."teacher_profile_id" without all the joins because users can only have one teacher_profile
      InductionRecord.select(
        <<-SQL,
          FIRST_VALUE(induction_records.id) OVER (
            PARTITION BY "participant_profiles"."teacher_profile_id"
            ORDER BY induction_records.end_date ASC NULLS FIRST, induction_records.start_date ASC, induction_records.created_at ASC
          ) AS id
        SQL
      )
      .joins(:participant_profile)
    end
  end
end
