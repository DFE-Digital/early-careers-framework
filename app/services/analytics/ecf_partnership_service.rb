# frozen_string_literal: true

module Analytics
  class ECFPartnershipService
    class << self
      def upsert_record(partnership)
        return unless %w[test development production].include? Rails.env

        record = Analytics::ECFPartnership.find_or_initialize_by(partnership_id: partnership.id)
        record.school_id = partnership.school.id
        record.school_name = partnership.school.name
        record.school_urn = partnership.school.urn

        record.lead_provider_id = partnership.lead_provider.id
        record.lead_provider_name = partnership.lead_provider.name

        record.cohort_id = partnership.cohort.id
        record.cohort = partnership.cohort.start_year

        record.delivery_partner_id = partnership.delivery_partner.id
        record.delivery_partner_name = partnership.delivery_partner.name

        record.challenged_at = partnership.challenged_at
        record.challenge_reason = partnership.challenge_reason
        record.challenge_deadline = partnership.challenge_deadline

        record.pending = partnership.pending

        record.report_id = partnership.report_id

        record.relationship = partnership.relationship

        record.created_at = partnership.created_at
        record.updated_at = partnership.updated_at

        record.save!
      end
    end
  end
end
