# frozen_string_literal: true

require "jsonapi/serializer/instrumentation"

module Api
  module V1
    class TransferSerializer
      include JSONAPI::Serializer
      include JSONAPI::Serializer::Instrumentation

      set_id :id
      set_type :'participant-transfer'

      attribute :updated_at do |participant_profile|
        participant_profile.user.updated_at.rfc3339
      end

      attribute :external_identifier do |participant_profile|
        participant_profile.participant_identity.external_identifier
      end

      attribute :transfers do |participant_profile|
        latest_leaving_induction_record = participant_profile.induction_records.sort_by(&:created_at).select {|i| i.induction_status == "leaving"}.last

        latest_joining_induction_record = participant_profile.induction_records.sort_by(&:created_at).select {|i| i.induction_status != "leaving" && i.start_date >= latest_leaving_induction_record.end_date && i.induction_programme.school_cohort.school_id != latest_leaving_induction_record.induction_programme.school_cohort.school_id && i&.induction_programme&.partnership&.lead_provider.present? }.first

        [
          {
            leaving: {
              school_urn: latest_leaving_induction_record.induction_programme&.school_cohort&.school&.urn,
              provider: latest_leaving_induction_record.induction_programme&.partnership&.lead_provider&.name,
              date: latest_leaving_induction_record.end_date
            },
            joining: {
              school_urn: latest_joining_induction_record&.induction_programme&.school_cohort&.school&.urn,
              provider: latest_joining_induction_record&.induction_programme&.partnership&.lead_provider&.name,
              date: latest_joining_induction_record&.start_date
            }
          }
        ]
      end
    end
  end
end
