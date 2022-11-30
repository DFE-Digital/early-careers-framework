# frozen_string_literal: true

require "jsonapi/serializer/instrumentation"

module Api
  module V1
    class ECFUserSerializer
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

      set_id :id
      attributes :email, :full_name

      attributes :user_type do |user|
        case find_oldest_profile(user)&.type
        when ParticipantProfile::ECT.name
          USER_TYPES[:early_career_teacher]
        when ParticipantProfile::Mentor.name
          USER_TYPES[:mentor]
        else
          USER_TYPES[:other]
        end
      end

      attributes :core_induction_programme do |user|
        core_induction_programme = find_core_induction_programme(user)

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

      attributes :induction_programme_choice do |user|
        find_school_cohort(user)&.induction_programme_choice
      end

      attributes :registration_completed do |user|
        find_oldest_profile(user)&.completed_validation_wizard?
      end

      attributes :cohort do |user|
        find_school_cohort(user)&.cohort&.start_year
      end

      def self.find_oldest_profile(user)
        user.teacher_profile.ecf_profiles.min_by(&:created_at)
      end

      def self.find_school_cohort(user)
        find_oldest_profile(user)&.school_cohort
      end

      def self.find_core_induction_programme(user)
        find_oldest_profile(user)&.core_induction_programme ||
          find_school_cohort(user)&.core_induction_programme
      end
    end
  end
end
