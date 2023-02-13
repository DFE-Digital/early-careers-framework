# frozen_string_literal: true

module Admin
  module NPQ
    module Applications
      class NonSchoolRegistrantsController < Admin::BaseController
        skip_after_action :verify_authorized, only: :index
        skip_after_action :verify_policy_scoped, except: :index

        def index
          @npq_applications = policy_scope(
            NPQApplication
              .does_not_work_in_school
              .does_not_work_in_childcare
              .not_eligible_for_funding
              .no_institution
              .eager_load(:npq_course, participant_identity: :user)
          ).all
        end

        def show
          authorize NPQApplication

          @npq_application = NPQApplication.find(params[:id])
        end
      end
    end
  end
end
