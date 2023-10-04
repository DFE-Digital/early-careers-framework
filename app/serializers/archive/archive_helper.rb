# frozen_string_literal: true

module Archive
  module ArchiveHelper
    extend ActiveSupport::Concern

    class_methods do
      def add_user_metadata(user)
        [
          user.id,
          user.full_name,
          user.email,
          user.teacher_profile&.trn,
        ].compact
      end
    end
  end
end
