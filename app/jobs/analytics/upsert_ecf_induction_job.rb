# frozen_string_literal: true

class Analytics::UpsertECFInductionJob < ApplicationJob
  def perform(induction_record_id:)
    induction_record = InductionRecord.find_by(id: induction_record_id)
    Analytics::ECFInductionService.upsert_record(induction_record) if induction_record
  end
end
