# frozen_string_literal: true

module NewSeeds
  module Scenarios
    module Users
      # not sure how useful this class is, it's just wrapping the factory at the moment
      class AppropriateBodyUser
        attr_reader :user, :appropriate_body, :number, :new_user_attributes

        def initialize(user: nil, appropriate_body: nil, full_name: nil, email: nil)
          @user = user
          @appropriate_body = appropriate_body
          @new_user_attributes = { full_name:, email: }.compact
        end

        def build
          ab_user = user || FactoryBot.create(:seed_user, **new_user_attributes)
          ab = appropriate_body || FactoryBot.create(:seed_appropriate_body)

          FactoryBot.create(:seed_appropriate_body_profile, user: ab_user, appropriate_body: ab)
        end
      end
    end
  end
end
