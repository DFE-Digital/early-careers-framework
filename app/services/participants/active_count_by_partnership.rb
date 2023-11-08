# frozen_string_literal: true

module Participants
  class ActiveCountByPartnership < BaseService
    include Api::Concerns::FetchLatestInductionRecords

    def call
      default_hash = Hash.new do |h, partnership_id|
        h[partnership_id] = { ect_count: 0, mentor_count: 0 }
      end

      query_counts.each_with_object(default_hash) do |((partnership_id, type), count), hash|
        hash[partnership_id][type_key(type)] = count
      end
    end

  private

    attr_reader :partnerships, :lead_provider

    def initialize(partnerships:, lead_provider:)
      @partnerships = partnerships
      @lead_provider = lead_provider
    end

    def query_counts
      @query_counts ||= ParticipantProfile::ECF
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

    def type_key(type)
      "#{type.split('::').last}_count".downcase.to_sym
    end
  end
end
