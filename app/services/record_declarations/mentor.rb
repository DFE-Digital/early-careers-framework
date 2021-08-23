# frozen_string_literal: true

module RecordDeclarations
  module Mentor
    extend ActiveSupport::Concern

    included do
      extend MentorClassMethods
      include ECF
      delegate :mentor_profile, to: :user
    end

    def user_profile
      mentor_profile
    end

    module MentorClassMethods
      def valid_courses_for_user
        %w[ecf-mentor]
      end
    end
  end
end
