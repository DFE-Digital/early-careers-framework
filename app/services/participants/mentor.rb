# frozen_string_literal: true

module Participants
  module Mentor
    include ECF
    extend ActiveSupport::Concern
    included do
      extend MentorClassMethods
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
  end
end
