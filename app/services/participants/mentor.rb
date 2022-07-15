# frozen_string_literal: true

module Participants
  module Mentor
    include ECF

    extend ActiveSupport::Concern

    included do
      extend MentorClassMethods

      validate :validate_profile_not_withdrawn
    end

    def mentor_profile
      return unless participant_identity

      @mentor_profile ||= participant_identity.participant_profiles.active_record.mentors.first
    end
    alias_method :user_profile, :mentor_profile

    module MentorClassMethods
      def valid_courses
        %w[ecf-mentor]
      end
    end

  private

    def validate_profile_not_withdrawn
      return unless participant_identity

      if mentor_profile.nil? && participant_identity.participant_profiles.mentors.any?
        errors.add :base, I18n.t("withdrawn_participant")
      end
    end
  end
end
