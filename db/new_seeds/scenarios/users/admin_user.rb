# frozen_string_literal: true

module NewSeeds
  module Scenarios
    module Users
      class AdminUser
        attr_reader :user, :admin_profile

        def initialize(user: nil, full_name: nil, email: nil)
          @user = user || FactoryBot.build(:seed_user, **{ full_name:, email: }.compact)
        end

        def build
          @admin_profile = FactoryBot.create(:seed_admin_profile, user:)

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
