# frozen_string_literal: true

module Identity
  class PrimaryUser < BaseService
    class << self
      def find_by(trn:)
        TeacherProfile
          .includes(:user)
          .oldest_first
          .where(trn:)
          .first
          &.user
      end
    end
  end
end
