# frozen_string_literal: true

module Admin
  module NPQ
    module Applications
      class NonSchoolRegistrantsController < Admin::BaseController
        skip_after_action :verify_authorized, only: :index
        skip_after_action :verify_policy_scoped, except: :index

        def index
          @participant_profiles = policy_scope(
            NPQApplication.eager_load(participant_identity: :user)
          ).all
        end
      end
    end
  end
end
