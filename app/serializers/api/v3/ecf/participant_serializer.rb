# frozen_string_literal: true

require "jsonapi/serializer/instrumentation"

module Api
  module V3
    module ECF
      class ParticipantSerializer
        include JSONAPI::Serializer
        include JSONAPI::Serializer::Instrumentation

        class << self
          def trn(record)
            record.teacher_profile&.trn || record.ecf_participant_validation_data&.trn
          end

          def validated_trn(record)
            eligibility = record.ecf_participant_eligibility&.reason
            eligibility.present? && eligibility != "different_trn"
          end

          def eligible_for_funding?(record)
            ecf_participant_eligibility_status = record.ecf_participant_eligibility&.status
            return if ecf_participant_eligibility_status.nil?
            return true if ecf_participant_eligibility_status == "eligible"
            return false if ecf_participant_eligibility_status == "ineligible"
          end

          def withdrawal(profile:, cpd_lead_provider:, latest_induction_record:)
            if latest_induction_record&.training_status_withdrawn?
              latest_participant_profile_state = profile.participant_profile_states.sort { |a, b| b.created_at <=> a.created_at }.find { |pps| pps.state == ParticipantProfileState.states[:withdrawn] && pps.cpd_lead_provider_id == cpd_lead_provider.id }
              if latest_participant_profile_state.present?
                {
                  reason: latest_participant_profile_state.reason,
                  date: latest_participant_profile_state.created_at.rfc3339,
                }
              end
            end
          end

          def deferral(profile:, cpd_lead_provider:, latest_induction_record:)
            if latest_induction_record&.training_status_deferred?
              latest_participant_profile_state = profile.participant_profile_states.sort { |a, b| b.created_at <=> a.created_at }.find { |pps| pps.state == ParticipantProfileState.states[:deferred] && pps.cpd_lead_provider_id == cpd_lead_provider.id }
              if latest_participant_profile_state.present?
                {
                  reason: latest_participant_profile_state.reason,
                  date: latest_participant_profile_state.created_at.rfc3339,
                }
              end
            end
          end

          def participant_status(induction_record:)
            if induction_record.end_date.present?
              induction_record.end_date > Time.zone.now ? "leaving" : "left"
            elsif induction_record.start_date > Time.zone.now
              "joining"
            else
              case induction_record.induction_status
              when "active", "completed"
                "active"
              when "withdrawn", "changed"
                "withdrawn"
              end
            end
          end
        end

        set_id :id

        set_type :participant

        attribute :full_name

        attribute(:teacher_reference_number) do |object|
          object.teacher_profile&.trn
        end

        attribute(:updated_at) do |object|
          object.updated_at.rfc3339
        end

        attribute(:ecf_enrolments) do |object, params|
          object.participant_profiles.select { |pp| [ParticipantProfile::ECT.name, ParticipantProfile::Mentor.name].include?(pp.type) }.map { |profile|
            latest_induction_record = profile.induction_records.first

            next unless params[:cpd_lead_provider] && latest_induction_record.present? && latest_induction_record.induction_programme&.partnership&.lead_provider&.cpd_lead_provider == params[:cpd_lead_provider]

            {
              training_record_id: profile.id,
              email: latest_induction_record.preferred_identity&.email.presence || object.email,
              mentor_id: latest_induction_record.participant_profile.ect? ? latest_induction_record.mentor_profile&.participant_identity&.user_id : nil,
              school_urn: latest_induction_record.induction_programme&.school_cohort&.school&.urn,
              participant_type: profile.ect? ? :ect : :mentor,
              cohort: latest_induction_record.induction_programme&.school_cohort&.cohort&.start_year&.to_s,
              training_status: latest_induction_record&.training_status,
              participant_status: participant_status(induction_record: latest_induction_record),
              teacher_reference_number_validated: trn(profile).nil? ? nil : validated_trn(profile).present?,
              eligible_for_funding: eligible_for_funding?(profile),
              pupil_premium_uplift: profile.pupil_premium_uplift,
              sparsity_uplift: profile.sparsity_uplift,
              schedule_identifier: profile.schedule&.schedule_identifier,
              validation_status: nil,
              delivery_partner_id: latest_induction_record&.delivery_partner_id,
              withdrawal: withdrawal(profile:, cpd_lead_provider: params[:cpd_lead_provider], latest_induction_record:),
              deferral: deferral(profile:, cpd_lead_provider: params[:cpd_lead_provider], latest_induction_record:),
              created_at: profile.created_at.rfc3339,
            }
          }.compact
        end
      end
    end
  end
end
