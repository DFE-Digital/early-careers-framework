# frozen_string_literal: true

module Admin
  module NPQ
    module Applications
      class NonSchoolRegistrantsController < Admin::BaseController
        StatusOption = Struct.new(:value, :label)

        skip_after_action :verify_authorized, only: :index
        skip_after_action :verify_policy_scoped, except: :index

        before_action :load_npq_application, except: :index

        def index
          @npq_applications = policy_scope(
            NPQApplication
              .does_not_work_in_school
              .does_not_work_in_childcare
              .not_eligible_for_funding
              .no_institution
              .eager_load(:npq_course, participant_identity: :user),
          ).all
        end

        def show; end

        def edit
          @status_options =
            Admin::NPQApplications::EligibilityImport::ApplicationUpdater::VALID_FUNDING_ELIGIBILITY_STATUS_CODES
              .map { |code| StatusOption.new(code, code.humanize) }
        end

        def update
          @npq_application.assign_attributes(npq_application_params)

          if @npq_application.valid?
            new_status = @npq_application.funding_eligiblity_status_code == "funded"

            @npq_application.eligible_for_funding = new_status
            @npq_application.save!

            name = @npq_application.participant_identity.user.full_name

            flash[:success] = {
              title: "#{name} updated",
              content: "#{name} has been marked '#{@npq_application.funding_eligiblity_status_code.humanize.downcase}' and is #{new_status ? 'eligible' : 'not eligible'} for funding",
            }

            redirect_to admin_npq_applications_non_school_registrants_path
          else
            render(:edit)
          end
        end

      private

        def load_npq_application
          authorize NPQApplication

          @npq_application = NPQApplication
            .eager_load(:profile, participant_identity: :user)
            .find(params[:id])
        end

        def npq_application_params
          params.require(:npq_application).permit(:funding_eligiblity_status_code)
        end
      end
    end
  end
end
