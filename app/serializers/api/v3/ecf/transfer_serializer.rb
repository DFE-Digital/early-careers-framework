# frozen_string_literal: true

require "jsonapi/serializer/instrumentation"

module Api
  module V3
    module ECF
      class TransferSerializer
        include JSONAPI::Serializer
        include JSONAPI::Serializer::Instrumentation

        class << self
          def transfer_type_for(leaving_induction_record:, joining_induction_record: nil)
            if joining_induction_record
              old_provider = leaving_induction_record.induction_programme.partnership&.lead_provider
              new_provider = joining_induction_record.induction_programme.partnership&.lead_provider
              if old_provider && new_provider && old_provider != new_provider
                "new_provider"
              else
                "new_school"
              end
            else
              "unknown"
            end
          end

          def status_for(leaving_induction_record:, joining_induction_record: nil)
            transfer_date = [
              leaving_induction_record.end_date,
              joining_induction_record&.start_date,
            ].compact.max

            if transfer_date > Time.zone.today
              "incomplete"
            else
              "complete"
            end
          end
        end

        set_id :id
        set_type :'participant-transfer'

        attribute :updated_at do |user, params|
          transfers = user.participant_profiles.flat_map do |participant_profile|
            BuildTransfers.new(participant_profile:, cpd_lead_provider: params[:cpd_lead_provider]).call
          end

          # default to user updated_at for edge-cases where transfers not found
          transfers.flatten.compact.map(&:updated_at).max&.rfc3339 || user.updated_at.rfc3339
        end

        attribute :transfers do |user, params|
          user.participant_profiles.map { |participant_profile|
            transfers = BuildTransfers.new(participant_profile:, cpd_lead_provider: params[:cpd_lead_provider]).call

            transfers.map do |leaving_induction_record, joining_induction_record|
              transfer = {
                training_record_id: participant_profile.id,
                transfer_type: transfer_type_for(leaving_induction_record:, joining_induction_record:),
                status: status_for(leaving_induction_record:, joining_induction_record:),
                created_at: leaving_induction_record.created_at.rfc3339,
                leaving: {
                  school_urn: leaving_induction_record.induction_programme&.school_cohort&.school&.urn,
                  provider: leaving_induction_record.induction_programme&.partnership&.lead_provider&.name,
                  date: leaving_induction_record.end_date&.strftime("%Y-%m-%d"),
                },
                joining: nil,
              }

              if joining_induction_record
                transfer[:joining] = {
                  school_urn: joining_induction_record.induction_programme&.school_cohort&.school&.urn,
                  provider: joining_induction_record.induction_programme&.partnership&.lead_provider&.name,
                  date: joining_induction_record.start_date&.strftime("%Y-%m-%d"),
                }
              end

              transfer
            end
          }.flatten.compact
        end
      end
    end
  end
end
