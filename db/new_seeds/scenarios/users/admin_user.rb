# frozen_string_literal: true

module NewSeeds
  module Scenarios
    module Users
      class AdminUser
        attr_reader :user, :new_user_attributes, :admin_profile

        def initialize(user: nil, full_name: nil, email: nil)
          @user = user
          @new_user_attributes = { full_name:, email: }.compact
        end

        def build
          admin_user = user || FactoryBot.create(:seed_user, **new_user_attributes)

          @admin_profile = FactoryBot.create(:seed_admin_profile, user: admin_user)

          self
        end

        def with_super_user
          admin_profile.update!(super_user: true)

          self
        end
      end
    end
  end
end
