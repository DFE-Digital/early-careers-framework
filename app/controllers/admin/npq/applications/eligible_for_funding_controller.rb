# frozen_string_literal: true

module Admin
  module NPQ
    module Applications
      class EligibleForFundingController < Admin::BaseController
        StatusOption = Struct.new(:value, :label)

        skip_after_action :verify_policy_scoped

        before_action :assign_npq_application

        def edit
          @status_options = [
            StatusOption.new(true, t(".true")),
            StatusOption.new(false, t(".false")),
          ]
        end

        def update
          @npq_application.assign_attributes(eligible_for_funding_params)

          set_eligibility_status(eligible_for_funding_params["eligible_for_funding"])
          name = @npq_application.participant_identity.user.full_name

          if @npq_application.save(context: :admin)
            update_admin_signatures if @npq_application.saved_change_to_eligible_for_funding?
            flash[:success] = {
              title: "#{name} updated",
              content: "#{name} has been marked '#{@npq_application.funding_eligiblity_status_code.to_s.humanize.downcase}'",
            }
          else
            flash[:alert] = "Failed to save new eligibility"
          end
          redirect_to admin_npq_applications_edge_case_path(@npq_application)
        end

      private

        def set_eligibility_status(eligible_for_funding)
          case eligible_for_funding
          when "true"
            @npq_application.funding_eligiblity_status_code = :marked_funded_by_policy
          when "false"
            @npq_application.funding_eligiblity_status_code = :marked_ineligible_by_policy
          end
        end

        def assign_npq_application
          authorize NPQApplication

          @npq_application = NPQApplication.find(params[:id])
        end

        def eligible_for_funding_params
          params.require(:npq_application).permit(:eligible_for_funding)
        end

        def update_admin_signatures
          UpdateEligibleForFundingRelatedInformation.new(
            @npq_application,
            eligible_for_funding_updated_by: current_user,
            eligible_for_funding_updated_at: Time.zone.now,
          ).call
        end
      end
    end
  end
end
