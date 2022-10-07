# frozen_string_literal: true

module Admin
  class ParticipantsController < Admin::BaseController
    skip_after_action :verify_policy_scoped, except: :index
    skip_after_action :verify_authorized, only: :index

    before_action :load_participant, except: :index
    before_action :historical_induction_records, only: :show, unless: -> { @participant_profile.npq? }
    before_action :latest_induction_record, only: :show, unless: -> { @participant_profile.npq? }
    before_action :participant_declarations, only: :show, unless: -> { @participant_profile.npq? }

    def show; end

    def index
      search_term = params[:query]
      type        = params[:type]

      @participant_profiles = Admin::Participants::Search
        .call(policy_scope(ParticipantProfile), search_term:, type:)
    end

    def edit_name; end

    def update_name
      if @participant_profile.user.update(params.require(:user).permit(:full_name))
        if @participant_profile.ect?
          set_success_message(heading: "The ECT’s name has been updated")
        else
          set_success_message(heading: "The mentor’s name has been updated")
        end
        redirect_to admin_participants_path
      else
        render "admin/participants/edit_name"
      end
    end

    def edit_email; end

    def update_email
      user = @participant_profile.user
      user.assign_attributes(params.require(:user).permit(:email))

      if user.save
        if @participant_profile.ect?
          set_success_message(heading: "The ECT’s email address has been updated")
        else
          set_success_message(heading: "The mentor’s email address has been updated")
        end
        redirect_to admin_participants_path
      else
        render "admin/participants/edit_email"
      end
    end

    def remove; end

    def destroy
      Induction::RemoveParticipantFromSchool.call(participant_profile: @participant_profile)
      render :destroy_success
    end

  private

    def load_participant
      @participant_profile = ParticipantProfile
        .eager_load(:teacher_profile).find(params[:id])

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
        .ordered_historically
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
  end
end
