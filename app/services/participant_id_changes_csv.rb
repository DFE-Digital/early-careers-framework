# frozen_string_literal: true

require "csv"

class ParticipantIdChangesCsv < BaseService
  include Api::Concerns::FetchLatestInductionRecords

  def initialize(cpd_lead_provider:, from_date: 30.days.ago)
    @cpd_lead_provider = cpd_lead_provider
    @from_date = from_date.beginning_of_day
  end

  def call
    CSV.generate do |csv|
      csv << %w[
        participant_id
        from_participant_id
        to_participant_id
        changed_at
      ]

      ParticipantIdChange.where(created_at: from_date..).order(created_at: :asc).each do |c|
        next unless cpd_lead_provider?(c.user)

        csv << [
          c.user_id,
          c.from_participant_id,
          c.to_participant_id,
          c.created_at.rfc3339,
        ]
      end
    end
  end

private

  attr_reader :cpd_lead_provider, :from_date

  delegate :lead_provider, :npq_lead_provider,
           to: :cpd_lead_provider

  def cpd_lead_provider?(user)
    user.participant_profiles.each do |pp|
      if pp.npq? && pp.npq_application.npq_lead_provider == npq_lead_provider
        return true
      elsif pp.ecf? && pp.latest_induction_record_for(cpd_lead_provider:)
        return true
      end
    end

    false
  end
end
