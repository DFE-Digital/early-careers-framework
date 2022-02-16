# frozen_string_literal: true

module Admin
  module Schools
    module Cohorts
      class ChallengePartnershipController < ::Admin::BaseController
        include Multistep::Controller
        form ChallengePartnershipForm, as: :challenge_partnership_form

        skip_after_action :verify_policy_scoped
        skip_after_action :verify_authorized

        setup_form do |form|
          school = School.friendly.find params[:school_id]
          cohort = ::Cohort.find_by(start_year: params[:id])
          form.partnership = authorize(Partnership.find_by(school: school, cohort: cohort), :update?)
        end

        abandon_journey_path do
          admin_school_cohorts_path(partnership.school)
        end

        def complete
          super

          set_success_message heading: "Induction programme has been changed"
          redirect_to admin_school_cohorts_path(school_id: form.partnership.school.slug)
        end

      private

        def set_challenge_partnership_form
          @challenge_partnership_form = ChallengePartnershipForm.new(
            params.require(:challenge_partnership_form).permit(:partnership_id, :challenge_reason),
          )
        end

        def partnership
          challenge_partnership_form&.partnership
        end

        def authorize_partnership
          authorize(partnership, :update?)
        end
      end
    end
  end
end
