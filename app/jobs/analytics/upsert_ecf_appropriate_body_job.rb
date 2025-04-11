# frozen_string_literal: true

class Analytics::UpsertECFAppropriateBodyJob < ApplicationJob
  def perform(appropriate_body_id:)
    appropriate_body = AppropriateBody.find_by(id: appropriate_body_id)
    Analytics::ECFAppropriateBodyService.upsert_record(appropriate_body) if appropriate_body
  end
end
