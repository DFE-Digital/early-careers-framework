# frozen_string_literal: true

module Api
  module V1
    class UsersQuery
      attr_reader :updated_since, :email

      def initialize(updated_since: nil, email: nil)
        @updated_since = updated_since
        @email         = email
      end

      def all
        users = User.all
        users = users.changed_since(updated_since) if updated_since.present?
        users = users.left_joins(:participant_identities).where(participant_identities: { email: }).or(users.where(email:)) if email.present?
        users.distinct
      end
    end
  end
end
