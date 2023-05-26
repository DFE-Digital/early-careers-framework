# frozen_string_literal: true

class Analytics::UpsertECFAppropriateBodyJob < ApplicationJob
  def perform(appropriate_body:)
    # Analytics::ECFAppropriateBodyService.upsert_record(appropriate_body)
  end
end
