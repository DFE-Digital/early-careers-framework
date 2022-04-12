# frozen_string_literal: true

module Admin
  class ParticipantsController < Admin::BaseController
    skip_after_action :verify_policy_scoped, except: :index
    skip_after_action :verify_authorized, only: :index

    before_action :load_participant, except: :index
    before_action :historical_induction_records, only: :show, unless: -> { @participant_profile.npq? }
    before_action :latest_induction_record, only: :show, unless: -> { @participant_profile.npq? }

    def show; end

    def index
      if FeatureFlag.active?(:change_of_circumstances)
        @participant_profiles = search
      else
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
      # FIXME: this will need looking at when we properly have mentors at multiple schools
      @participant_profile.current_induction_record&.withdrawing!
      # belt and braces while we transition
      @participant_profile.withdrawn_record!
      if @participant_profile.mentor?
        # FIXME: decide how to handle removing mentor_profile_id from induction_records
        # this vvv will sync to the induction records but we should make it a new induction record
        @participant_profile.mentee_profiles.update_all(mentor_profile_id: nil)
      end

      render :destroy_success
    end

  private

    def load_participant
      @participant_profile = ParticipantProfile.find(params[:id])
      authorize @participant_profile, policy_class: @participant_profile.policy_class
    end

    def search
      scope = policy_scope(ParticipantProfile).joins(participant_identity: :user)

      if params[:type].present?
        scope = scope.where(type: params[:type])
      end

      if params[:query].present?
        query = "%#{params.fetch(:query).downcase}%"
        profile_ids = InductionRecord.current.ransack(induction_programme_school_cohort_school_name_or_induction_programme_school_cohort_school_urn_i_cont: params[:query]).result.pluck(:participant_profile_id)
        scope = scope.where("participant_profiles.id IN (?) OR users.full_name ILIKE ?", profile_ids, query)
      end

      scope.order("DATE(users.created_at) ASC, users.full_name")
    end

    def historical_induction_records
      @historical_induction_records ||= @participant_profile.induction_records.order(created_at: :desc).offset(1)
    end

    def latest_induction_record
      @latest_induction_record ||= @participant_profile.current_induction_record
    end
  end
end
