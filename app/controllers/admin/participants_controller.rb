# frozen_string_literal: true

module Admin
  class ParticipantsController < Admin::BaseController
    skip_after_action :verify_policy_scoped, except: :index
    skip_after_action :verify_authorized, only: :index

    before_action :load_participant, except: :index

    def show; end

    def index
      school_cohort_ids = SchoolCohort.ransack(school_name_or_school_urn_cont: params[:query]).result.pluck(:id)
      query = "%#{(params[:query] || '').downcase}%"
      @participant_profiles = policy_scope(ParticipantProfile).joins(:user)
                                                              .active_record
                                                              .includes(:validation_decisions)
                                                              .where("lower(users.full_name) LIKE ? OR school_cohort_id IN (?)", query, school_cohort_ids)
                                                              .order("DATE(users.created_at) asc, users.full_name")

      if params[:type].present?
        @participant_profiles = @participant_profiles.where(type: params[:type])
      end
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
      @participant_profile.withdrawn_record!
      @participant_profile.mentee_profiles.update_all(mentor_profile_id: nil) if @participant_profile.mentor?
      Analytics::UpsertECFParticipantProfileJob.perform_later(participant_profile: @participant_profile)

      render :destroy_success
    end

  private

    def load_participant
      @participant_profile = ParticipantProfile.find(params[:id])
      authorize @participant_profile, policy_class: @participant_profile.policy_class
    end
  end
end
