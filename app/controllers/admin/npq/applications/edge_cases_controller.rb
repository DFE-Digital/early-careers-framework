# frozen_string_literal: true

module Admin
  module NPQ
    module Applications
      class EdgeCasesController < Admin::BaseController
        StatusOption = Struct.new(:value, :label)

        skip_after_action :verify_authorized, only: :index
        skip_after_action :verify_policy_scoped, except: :index

        before_action :load_npq_application, except: :index

        def index
          @npq_applications = policy_scope(
            NPQApplication
              .does_not_work_in_school
              .does_not_work_in_childcare
              .edge_case_statuses
              .eager_load(:npq_course, participant_identity: :user),
          ).all
        end

        def show
          @application = NPQApplication.includes(:participant_identity)
                                     .joins({ participant_identity: :user })
                                     .find(params[:id])
        end

      private

        def load_npq_application
          authorize NPQApplication

          @npq_application = NPQApplication
            .eager_load(:profile, participant_identity: :user)
            .find(params[:id])
        end
      end
    end
  end
end
