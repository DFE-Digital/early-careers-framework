# frozen_string_literal: true

class Analytics::UpsertECFPartnershipJob < ApplicationJob
  def perform(partnership:)
    # Analytics::ECFPartnershipService.upsert_record(partnership)
  end
end
