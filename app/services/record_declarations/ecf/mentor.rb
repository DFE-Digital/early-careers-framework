# frozen_string_literal: true

module RecordDeclarations
  class ECF::Mentor < ECF
    delegate :mentor_profile, to: :user

    class << self
      def valid_courses
        %w[ecf-mentor]
      end
    end

    def user_profile
      mentor_profile
    end
  end
end
