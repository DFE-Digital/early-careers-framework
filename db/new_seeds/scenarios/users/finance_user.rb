# frozen_string_literal: true

module NewSeeds
  module Scenarios
    module Users
      class FinanceUser
        attr_reader :user

        def initialize(user: nil)
          @user = user
        end

        def build
          finance_user = user || FactoryBot.create(:seed_user)

          FactoryBot.create(:seed_finance_profile, user: finance_user)
        end
      end
    end
  end
end
