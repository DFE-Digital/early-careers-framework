# frozen_string_literal: true

module Participants
  module Mentor
    include ECF
    extend ActiveSupport::Concern
    included do
      extend MentorClassMethods
      delegate :mentor_profile, to: :user, allow_nil: true
    end

    def user_profile
      mentor_profile
    end

    module MentorClassMethods
      def valid_courses
        %w[ecf-mentor]
      end
    end
  end
end
