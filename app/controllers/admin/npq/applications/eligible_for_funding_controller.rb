# frozen_string_literal: true

module Admin
  module NPQ
    module Applications
      class EligibleForFundingController < Admin::BaseController
        StatusOption = Struct.new(:value, :label)

        skip_after_action :verify_authorized
        skip_after_action :verify_policy_scoped

        def edit
          @status_options = [
            StatusOption.new(true, "Yes"),
            StatusOption.new(false, "No"),
          ]
          @npq_application = NPQApplication.find(params[:id])
        end

        def update
          npq_application = NPQApplication.find(params[:id])
          npq_application.assign_attributes(eligible_for_funding_params)

          case eligible_for_funding_params["eligible_for_funding"]
          when "true"
            npq_application.funding_eligiblity_status_code = :marked_funded_by_policy
          when "false"
            npq_application.funding_eligiblity_status_code = :marked_ineligible_by_policy
          end

          if npq_application.save
            name = npq_application.participant_identity.user.full_name

            flash[:success] = {
              title: "#{name} updated",
              content: "#{name} has been marked '#{npq_application.funding_eligiblity_status_code.humanize.downcase}'",
            }
            redirect_to admin_npq_applications_edge_case_path(npq_application)
          else
            flash[:alert] = {
              title: "#{name} not updated",
              content: "#{name} failed to update",
            }

            render(:edit)
          end
        end

      private

        def eligible_for_funding_params
          params.require(:npq_application).permit(:eligible_for_funding)
        end
      end
    end
  end
end
