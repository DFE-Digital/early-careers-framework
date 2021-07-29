# frozen_string_literal: true

module Admin
  module Schools
    module Cohorts
      class ChallengePartnershipController < ::Admin::BaseController
        skip_after_action :verify_policy_scoped
        before_action :set_challenge_partnership_form, only: %i[confirm create]

        def new
          school = School.friendly.find params[:school_id]
          cohort = ::Cohort.find_by(start_year: params[:id])
          partnership = Partnership.find_by(school: school, cohort: cohort)
          authorize partnership, :update?
          @challenge_partnership_form = ChallengePartnershipForm.new(
            school_name: school.name,
            lead_provider_name: partnership.lead_provider.name,
            delivery_partner_name: partnership.delivery_partner.name,
            partnership_id: partnership.id,
          )
        end

        def confirm
          authorize @challenge_partnership_form.partnership, :update?
          render :new unless @challenge_partnership_form.valid?
        end

        def create
          authorize @challenge_partnership_form.partnership, :update?
          @challenge_partnership_form.challenge!
          set_success_message heading: "Induction programme has been changed"
          redirect_to admin_school_cohorts_path
        end

      private

        def set_challenge_partnership_form
          @challenge_partnership_form = ChallengePartnershipForm.new(
            params.require(:challenge_partnership_form).permit(:partnership_id, :challenge_reason, :lead_provider_name),
          )
        end
      end
    end
  end
end
