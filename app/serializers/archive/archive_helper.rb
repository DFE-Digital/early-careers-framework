# frozen_string_literal: true

module Archive
  module ArchiveHelper
    extend ActiveSupport::Concern

    class_methods do
      def add_user_metadata(user)
        {
          full_name: user.full_name,
          email: user.email,
          trn: user.teacher_profile&.trn,
          id: user.id,
          roles: user.user_roles,
        }
      end
    end
  end
end
