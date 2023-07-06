# frozen_string_literal: true

module AppropriateBodies
  class InductionRecordsQuery
    attr_reader :appropriate_body

    def initialize(appropriate_body:)
      @appropriate_body = appropriate_body
    end

    def induction_records
      join = InductionRecord
        .select(Arel.sql("DISTINCT FIRST_VALUE(induction_records.id) OVER (#{latest_induction_record_order}) AS latest_id"))
        .joins(:participant_profile)
        .where(appropriate_body:)

      InductionRecord.distinct
        .joins("JOIN (#{join.to_sql}) AS latest_induction_records ON latest_induction_records.latest_id = induction_records.id")
    end

  private

    def latest_induction_record_order
      <<~SQL
        PARTITION BY induction_records.participant_profile_id, induction_records.appropriate_body_id
          ORDER BY induction_records.created_at DESC
      SQL
    end
  end
end
