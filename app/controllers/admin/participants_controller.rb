# frozen_string_literal: true

module Admin
  class ParticipantsController < Admin::BaseController
    skip_after_action :verify_policy_scoped, except: :index
    skip_after_action :verify_authorized, only: :index

    before_action :load_participant, except: :index

    def index
      search_term = params[:query]
      type        = params[:type]

      @participant_profiles = Admin::Participants::Search
        .call(policy_scope(ParticipantProfile), search_term:, type:)
    end

    def remove; end

    def destroy
      Induction::RemoveParticipantFromSchool.call(participant_profile: @participant_profile)
      render :destroy_success
    end

  private

    def load_participant
      @participant_profile = ParticipantProfile
        .eager_load(:teacher_profile, :ecf_participant_validation_data).find(params[:id])

      authorize @participant_profile, policy_class: @participant_profile.policy_class
    end

    def induction_records
      @induction_records ||= @participant_profile
        .induction_records
        .eager_load(
          :appropriate_body,
          :preferred_identity,
          :schedule,
          induction_programme: {
            partnership: :lead_provider,
            school_cohort: %i[cohort school],
          },
          mentor_profile: :user,
        )
        .order(created_at: :desc)
    end

    def historical_induction_records
      @historical_induction_records ||= induction_records[1..]
    end

    def latest_induction_record
      @latest_induction_record ||= induction_records.first
    end

    def participant_declarations
      @participant_declarations ||= @participant_profile.participant_declarations
                                                        .includes(:cpd_lead_provider, :delivery_partner)
                                                        .order(created_at: :desc)
    end

    def validation_data
      @validation_data ||= @participant_profile.ecf_participant_validation_data || ECFParticipantValidationData.new(participant_profile: @participant_profile)
    end

    def eligibility_data
      @eligibility_data ||= ::EligibilityPresenter.new(@participant_profile.ecf_participant_eligibility)
    end

    def participant_identities
      @participant_identities ||= @participant_profile.user.participant_identities
    end
  end
end
