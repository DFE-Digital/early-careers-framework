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
        induction_record.preferred_identity.user_id
      end

      attributes :email, &:participant_email

      attributes :full_name do |induction_record|
        induction_record.preferred_identity.user.full_name
      end

      attributes :user_type do |induction_record|
        case induction_record.participant_profile.type
        when ParticipantProfile::ECT.name
          USER_TYPES[:early_career_teacher]
        when ParticipantProfile::Mentor.name
          USER_TYPES[:mentor]
        else
          USER_TYPES[:other]
        end
      end

      attributes :core_induction_programme do |induction_record|
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

      attributes :induction_programme_choice do |induction_record|
        induction_record.induction_programme.training_programme
      end

      attributes :registration_completed do |induction_record|
        induction_record.participant_profile.completed_validation_wizard?
      end

      attributes :cohort do |induction_record|
        induction_record.school_cohort.cohort.start_year
      end

      def self.find_core_induction_programme(induction_record)
        induction_record.induction_programme.core_induction_programme ||
          induction_record.participant_profile&.core_induction_programme ||
          induction_record.participant_profile&.school_cohort&.core_induction_programme
      end
    end
  end
end
