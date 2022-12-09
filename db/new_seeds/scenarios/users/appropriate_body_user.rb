# frozen_string_literal: true

module NewSeeds
  module Scenarios
    module Users
      class AppropriateBodyUser
        attr_reader :user, :appropriate_body

        def initialize(user: nil, appropriate_body: nil)
          @user = user
          @appropriate_body = appropriate_body
        end

        def build
          ab_user = user || FactoryBot.create(:seed_user)
          ab = appropriate_body || FactoryBot.create(:seed_appropriate_body)

          FactoryBot.create(:seed_appropriate_body_profile, user: ab_user, appropriate_body: ab)
        end
      end
    end
  end
end
