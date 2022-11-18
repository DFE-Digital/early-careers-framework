# frozen_string_literal: true

module Api::V1::ECF
  class InductionRecordsQuery
    attr_reader :updated_since, :email

    def initialize(updated_since: nil, email: nil)
      @updated_since = updated_since
      @email         = email
    end

    def all
      induction_records = InductionRecord
        .merge(InductionRecord.end_date_null.or(InductionRecord.end_date_in_future)).and(InductionRecord.start_date_in_past.or(InductionRecord.not_school_transfer))
        .joins(:induction_programme, :preferred_identity, :participant_profile)
        .merge(ParticipantProfile.ecf)

      if updated_since.present?
        induction_records = induction_records.where("induction_records.updated_at > ?", updated_since)
      end

      if email.present?
        induction_records = induction_records.where(preferred_identity: { email: })
      end

      induction_records
        .group_by(&:participant_profile_id)
        .transform_values(&:first)
        .values
    end
  end
end
