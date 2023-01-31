# frozen_string_literal: true

require "jsonapi/serializer/instrumentation"

module Api
  module V1
    class ParticipantFromQuerySerializer
      include JSONAPI::Serializer
      include JSONAPI::Serializer::Instrumentation

      class << self
        def trn(record)
          record["teacher_profile_trn"] || record["ecf_participant_validation_data_trn"]
        end

        def validated_trn(record)
          eligibility = record['ecf_participant_eligibility_reason']
          eligibility.present? && eligibility != "different_trn"
        end

        def eligible_for_funding?(record)
          ecf_participant_eligibility_status = record["ecf_participant_eligibility_status"]
          return if ecf_participant_eligibility_status.nil?
          return true if ecf_participant_eligibility_status == "eligible"
          return false if ecf_participant_eligibility_status == "ineligible"
        end

        def mentor_id_from(record)
          if record["participant_profile_type"] == "ParticipantProfile::ECT"
            record["mentor_user_id"]
          end
        end

        def participant_type_from(record)
            if record[:participant_profile_type] == "ParticipantProfile::ECT"
            :ect
          else
            :mentor
          end
        end

        def status_from(record)
          case record["induction_status"]
          when "active", "completed", "leaving"
            "active"
          when "withdrawn", "changed"
            "withdrawn"
          end
        end

        def teacher_reference_number_validated_from(record)
            if trn(record).nil?
              nil
            else
              validated_trn(record).present?
            end
        end
      end

      set_type :participant

      set_id :id, &:user_id

      attribute :full_name do |induction_record|
        induction_record.profiles["profiles"].first["full_name"]
      end

      attribute :teacher_reference_number do |induction_record|
        trn(induction_record.profiles["profiles"].first)
      end

       attribute :updated_at do |induction_record|
        induction_record.profiles["profiles"].flat_map do |profile|
          [
            profile["participant_profile_updated_at"],
            profile["user_updated_at"],
            profile["participant_identity_updated_at"],
            profile["updated_at"],
            ]
        end.flatten.compact.max
      end

      attribute :ecf_enrolments do |induction_record|
        induction_record.profiles["profiles"].map do |profile|
          {
            training_record_id: profile[:participant_profile_id],
            email: profile["preferred_identity_email"] || profile["user_email"],
            mentor_id: mentor_id_from(profile),
            school_urn: profile["schools_urn"],
            participant_type: participant_type_from(profile),
            cohort: profile["start_year"]&.to_s,
            participant_status: status_from(profile),
            training_status: profile["training_status"],
            teacher_reference_number: trn(profile),
            teacher_reference_number_validated: teacher_reference_number_validated_from(profile),
            eligible_for_funding: eligible_for_funding?(profile),
            pupil_premium_uplift: profile["pupil_premium_uplift"],
            sparsity_uplift: profile["sparsity_uplift"],
            schedule_identifier: profile["schedule_identifier"],
          }
        end
      end
    end
  end
end
