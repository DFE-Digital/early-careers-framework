# frozen_string_literal: true

class Analytics::UpsertECFInductionJob < ApplicationJob
  def perform(induction_record:)
    # Analytics::ECFInductionService.upsert_record(induction_record)
  end
end
