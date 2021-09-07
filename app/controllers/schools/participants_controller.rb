# frozen_string_literal: true

class Schools::ParticipantsController < Schools::BaseController
  before_action :set_school_cohort
  before_action :set_participant, except: %i[index email_used]
  before_action :check_feature_flag
  before_action :build_mentor_form, only: :edit_mentor
  before_action :set_mentors_added, only: %i[index show]

  def index
    @participant_profiles = policy_scope(
      @school_cohort.active_ecf_participant_profiles.includes(:user).order("users.full_name"),
    )

    redirect_to add_schools_participants_path if @participant_profiles.empty?
  end

  def show
    @mentor = @profile.mentor if @profile.ect?
  end

  def edit_name; end

  def update_name
    if @profile.user.update(params.require(:user).permit(:full_name))
      if @profile.ect?
        set_success_message(heading: "The ECT’s name has been updated")
      else
        set_success_message(heading: "The mentor’s name has been updated")
      end
      redirect_to schools_participant_path(id: @profile)
    else
      render "schools/participants/edit_name"
    end
  end

  def edit_email; end

  def update_email
    user = @profile.user
    user.assign_attributes(params.require(:user).permit(:email))
    redirect_to action: :email_used and return if email_used?

    if user.save
      if @profile.ect?
        set_success_message(heading: "The ECT’s email address has been updated")
      else
        set_success_message(heading: "The mentor’s email address has been updated")
      end
      redirect_to schools_participant_path(id: @profile)
    else
      render "schools/participants/edit_email"
    end
  end

  def email_used; end

  def edit_mentor; end

  def update_mentor
    if params[:participant_mentor_form].blank?
      build_mentor_form
      @mentor_form.valid?
      render :edit_mentor and return
    end

    @mentor_form = ParticipantMentorForm.new(participant_mentor_form_params.merge(school_id: @school.id, cohort_id: @cohort.id))

    if @mentor_form.valid?
      @profile.update!(mentor_profile: @mentor_form.mentor ? @mentor_form.mentor.mentor_profile : nil)

      flash[:success] = { title: "Success", heading: "The mentor for this participant has been updated" }
      redirect_to schools_participant_path(id: @profile)
    else
      render :edit_mentor
    end
  end

  def remove; end

  def destroy
    ActiveRecord::Base.transaction do
      @profile.withdrawn_record!
      @profile.mentee_profiles.update_all(mentor_profile_id: nil) if @profile.mentor?
      if @profile.request_for_details_sent?
        ParticipantMailer.participant_removed_by_sti(
          participant_profile: @profile,
          sti_profile: current_user.induction_coordinator_profile,
        ).deliver_later
      end
    end

    render :removed
  end

private

  def set_mentors_added
    @mentors_added = @school.mentor_profiles_for(@cohort).any?
  end

  def build_mentor_form
    @mentor_form = ParticipantMentorForm.new(
      mentor_id: @profile.mentor&.id,
      school_id: @school.id,
      cohort_id: @cohort.id,
    )
  end

  def check_feature_flag
    return if FeatureFlag.active?(:induction_tutor_manage_participants, for: @school)

    raise ActionController::RoutingError, "Not enabled for this school"
  end

  def set_participant
    @profile = ParticipantProfile.find(params[:participant_id] || params[:id])
    if %w[remove destroy].include?(action_name)
      authorize @profile, policy_class: ParticipantProfilePolicy
    else
      authorize @profile.user, policy_class: ParticipantPolicy
    end
  end

  def participant_mentor_form_params
    params.require(:participant_mentor_form).permit(:mentor_id)
  end

  def email_used?
    User.where.not(id: @profile.user.id).where(email: @profile.user.email).any?
  end
end
