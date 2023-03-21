# frozen_string_literal: true

module Admin
  module NPQ
    module Applications
      class EligibilityStatusController < Admin::BaseController
        StatusOption = Struct.new(:value, :label)

        skip_after_action :verify_policy_scoped

        before_action :assign_npq_application

        def edit
          @status_options = [
            StatusOption.new(:marked_ineligible_by_policy, t(".marked_ineligible_by_policy")),
            StatusOption.new(:awaiting_more_information, t(".awaiting_more_information")),
            StatusOption.new(:re_register, t(".re_register")),
          ]
        end

        def update
          @npq_application.assign_attributes(eligiblity_status_params)

          name = @npq_application.participant_identity.user.full_name
          if @npq_application.save

            flash[:success] = {
              title: "#{name} updated",
              content: "#{name} has been marked '#{@npq_application.funding_eligiblity_status_code.humanize.downcase}'",
            }
          else
            flash[:alert] = "Failed to save new status"
          end
          redirect_to admin_npq_applications_edge_case_path(@npq_application)
        end

      private

        def assign_npq_application
          authorize NPQApplication

          @npq_application = NPQApplication.find(params[:id])
        end

        def eligiblity_status_params
          params.require(:npq_application).permit(:funding_eligiblity_status_code)
        end
      end
    end
  end
end
