# frozen_string_literal: true

class PartnershipFinalisationJob < ApplicationJob
  discard_on ActiveJob::DeserializationError

  def perform(partnership_request)
    return if partnership_request.reload.blank?

    originator = partnership_request.versions.first.whodunnit
    PaperTrail.request(whodunnit: originator) do
      partnership_request.finalise!
    end
  end
end
