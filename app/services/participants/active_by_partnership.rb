# frozen_string_literal: true

module Participants
  class ActiveByPartnership < BaseService
    include Api::Concerns::FetchLatestInductionRecords

    def call
      ParticipantProfile::ECF
        .joins(induction_records: :induction_programme)
        .joins("JOIN (#{latest_induction_records_join.to_sql}) AS latest_induction_records
            ON latest_induction_records.latest_id = induction_records.id")
        .where(
          induction_programmes: { partnership_id: partnerships },
          status: :active,
        )
        .group(:partnership_id, :type)
        .count
    end

  private

    attr_reader :partnerships, :lead_provider

    def initialize(partnerships:, lead_provider:)
      @partnerships = partnerships
      @lead_provider = lead_provider
    end
  end
end
