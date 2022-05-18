# frozen_string_literal: true

module DeliveryPartners
  class ParticipantsController < BaseController
    def index
      @pagy, @participant_profiles = pagy(
        current_user.delivery_partner_profile.delivery_partner.ecf_participant_profiles
        .includes(
          :schedule,
          :school_cohort,
          :ecf_participant_eligibility,
          :ecf_participant_validation_data,
          user: %i[finance_profile teacher_profile admin_profile mentor_profile],
        ).order(updated_at: :desc),
        page: params[:page],
        items: 50,
      )
    end
  end
end
