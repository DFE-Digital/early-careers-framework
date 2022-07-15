# frozen_string_literal: true

module Participants
  module EarlyCareerTeacher
    include ECF

    extend ActiveSupport::Concern

    included do
      extend EarlyCareerTeacherClassMethods

      validate :validate_profile_not_withdrawn
    end

    def early_career_teacher_profile
      return unless participant_identity

      @early_career_teacher_profile ||= participant_identity.participant_profiles.active_record.ects.first
    end
    alias_method :user_profile, :early_career_teacher_profile

    module EarlyCareerTeacherClassMethods
      def valid_courses
        %w[ecf-induction]
      end
    end

  private

    def validate_profile_not_withdrawn
      return unless participant_identity

      if early_career_teacher_profile.nil? && participant_identity.participant_profiles.ects.any?
        errors.add :base, I18n.t("withdrawn_participant")
      end
    end
  end
end
