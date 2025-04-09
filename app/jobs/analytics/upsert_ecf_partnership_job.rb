# frozen_string_literal: true

class Analytics::UpsertECFPartnershipJob < ApplicationJob
  def perform(partnership_id:)
    partnership = Partnership.find_by(id: partnership_id)
    Analytics::ECFPartnershipService.upsert_record(partnership) if partnership
  end
end
