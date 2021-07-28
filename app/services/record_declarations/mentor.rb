# frozen_string_literal: true

# frozen_string_literal: true

module RecordDeclarations
  module Mentor
    extend ActiveSupport::Concern

    included do
      include ECF
      extend MentorClassMethods
      delegate :mentor_profile, to: :user
    end

    module MentorClassMethods
      def valid_courses
        %w[ecf-mentor]
      end
    end

    def user_profile
      mentor_profile
    end
  end
end
