# frozen_string_literal: true

require "jsonapi/serializer/instrumentation"

module Api
  module V1
    class ECFInductionRecordSerializer
      include JSONAPI::Serializer
      include JSONAPI::Serializer::Instrumentation

      set_type :user

      USER_TYPES = {
        early_career_teacher: "early_career_teacher",
        mentor: "mentor",
        other: "other",
      }.freeze

      CIP_TYPES = {
        ambition: "ambition",
        edt: "edt",
        teach_first: "teach_first",
        ucl: "ucl",
        none: "none",
      }.freeze

      set_id :id do |induction_record|
        find_participant_identity(induction_record)&.user_id
      end

      attributes :email do |induction_record|
        find_participant_identity(induction_record)&.email
      end

      attributes :full_name do |induction_record|
        find_participant_identity(induction_record)&.user&.full_name
      end

      attributes :user_type do |induction_record|
        if is_consistently_withdrawn(induction_record)
          USER_TYPES[:other]
        else
          case induction_record.participant_profile.type
          when ParticipantProfile::ECT.name
            USER_TYPES[:early_career_teacher]
          when ParticipantProfile::Mentor.name
            USER_TYPES[:mentor]
          else
            USER_TYPES[:other]
          end
        end
      end

      attributes :core_induction_programme do |induction_record|
        if is_consistently_withdrawn(induction_record)
          CIP_TYPES[:none]
        else
          core_induction_programme = find_core_induction_programme(induction_record)
          case core_induction_programme&.name
          when "Ambition Institute"
            CIP_TYPES[:ambition]
          when "Education Development Trust"
            CIP_TYPES[:edt]
          when "Teach First"
            CIP_TYPES[:teach_first]
          when "UCL Institute of Education"
            CIP_TYPES[:ucl]
          else
            CIP_TYPES[:none]
          end
        end
      end

      attributes :induction_programme_choice do |induction_record|
        induction_record.induction_programme.training_programme unless is_consistently_withdrawn(induction_record)
      end

      attributes :registration_completed do |induction_record|
        induction_record.participant_profile.completed_validation_wizard? unless is_consistently_withdrawn(induction_record)
      end

      attributes :cohort do |induction_record|
        induction_record.school_cohort.cohort.start_year unless is_consistently_withdrawn(induction_record)
      end

      def self.find_core_induction_programme(induction_record)
        induction_record.induction_programme.core_induction_programme ||
          induction_record.participant_profile&.core_induction_programme ||
          induction_record.participant_profile&.school_cohort&.core_induction_programme
      end

      def self.find_participant_identity(induction_record)
        induction_record.preferred_identity ||
          induction_record.participant_profile.participant_identity
      end

      # guard against some of the more complex scenarios where it is not possible to determine what is correct behaviour
      def self.is_consistently_withdrawn(induction_record)
        induction_record.withdrawn_induction_status? && induction_record.participant_profile.withdrawn_record?
      end
    end
  end
end
