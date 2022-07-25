# frozen_string_literal: true

class Schools::ParticipantsController < Schools::BaseController
  include AppropriateBodySelection::Controller

  before_action :set_school_cohort
  before_action :set_participant, except: %i[index email_used]
  before_action :build_mentor_form, only: :edit_mentor
  before_action :set_mentors_added, only: %i[index show]

  helper_method :can_appropriate_body_be_changed?, :participant_has_appropriate_body?

  def index
    if FeatureFlag.active?(:change_of_circumstances)
      @mentor_categories = CocSetParticipantCategories.call(@school_cohort, current_user, ParticipantProfile::Mentor)
      @ect_categories = CocSetParticipantCategories.call(@school_cohort, current_user, ParticipantProfile::ECT)
      @transferring_in = @ect_categories.transferring_in + @mentor_categories.transferring_in
      @transferring_out = @ect_categories.transferring_out + @mentor_categories.transferring_out
      @transferred = @ect_categories.transferred + @mentor_categories.transferred
    else
      @mentor_categories = SetParticipantCategories.call(@school_cohort, current_user, ParticipantProfile::Mentor)
      @ect_categories = SetParticipantCategories.call(@school_cohort, current_user, ParticipantProfile::ECT)
      @transferred = []
    end

    @withdrawn = @ect_categories.withdrawn + @mentor_categories.withdrawn
    @ineligible = @ect_categories.ineligible + @mentor_categories.ineligible
  end

  def show
    @induction_record = @profile.induction_records.for_school(@school).latest
    @first_induction_record = @profile.induction_records.for_school(@school).order(created_at: :asc).first
    @mentor_profile = @induction_record.mentor_profile
  end

  def edit_name
    render helpers.edit_name_template(params[:reason])
  end

  def update_name
    @old_name = @profile.full_name

    if @profile.user.update(params.require(:user).permit(:full_name))
      render :update_name
    else
      @profile.user.full_name = @old_name
      render "schools/participants/edit_name"
    end
  end

  def edit_email; end

  def update_email
    identity = @induction_record.preferred_identity
    identity.assign_attributes(params.require(:participant_identity).permit(:email))
    redirect_to action: :email_used and return if email_used?(identity.email)

    render "schools/participants/edit_email" and return if identity.invalid?

    Induction::ChangePreferredEmail.call(induction_record: @induction_record,
                                         preferred_email: identity.email)

    if @profile.ect?
      set_success_message(heading: "The ECT’s email address has been updated")
    else
      set_success_message(heading: "The mentor’s email address has been updated")
    end
    redirect_to schools_participant_path(id: @profile)
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
      Induction::ChangeMentor.call(induction_record: @profile.induction_records.for_school(@school).latest,
                                   mentor_profile: @mentor_form.mentor&.mentor_profile)

      flash[:success] = { title: "Success", heading: "The mentor for this participant has been updated" }
      redirect_to schools_participant_path(id: @profile)
    else
      render :edit_mentor
    end
  end

  def add_appropriate_body
    if can_appropriate_body_be_changed?
      start_appropriate_body_selection
    else
      redirect_to schools_participant_path(id: @profile.id)
    end
  end

  def remove; end

  def destroy
    Induction::RemoveParticipant.call(participant_profile: @profile,
                                      sit_profile: current_user.induction_coordinator_profile)
    render :removed
  end

private

  def set_mentors_added
    @mentors_added = if FeatureFlag.active?(:multiple_cohorts)
                       @school.school_mentors.any?
                     else
                       @school.mentor_profiles_for(@cohort).any?
                     end
  end

  def build_mentor_form
    @mentor_form = ParticipantMentorForm.new(
      mentor_id: @profile.mentor&.id,
      school_id: @school.id,
      cohort_id: @cohort.id,
    )
  end

  def set_participant
    @profile = ParticipantProfile.find(params[:participant_id] || params[:id])
    authorize @profile, policy_class: @profile.policy_class
    @induction_record = @profile.induction_records.for_school(@school).latest
  end

  def participant_mentor_form_params
    params.require(:participant_mentor_form).permit(:mentor_id)
  end

  def email_used?(email)
    User.where(email:).where.not(id: @profile.user.id).any? || ParticipantIdentity.where(email:).where.not(user_id: @profile.user.id).any?
  end

  def start_appropriate_body_selection
    super from_path: schools_participant_path(id: @profile.id),
          submit_action: :save_appropriate_body,
          school_name: @profile.user.full_name,
          ask_appointed: false
  end

  def save_appropriate_body
    @induction_record.update!({ appropriate_body_id: @appropriate_body_form.body_id })
    redirect_to appropriate_body_from_path
  end

  def participant_has_appropriate_body?
    @induction_record.appropriate_body.present?
  end

  def can_appropriate_body_be_changed?
    @school_cohort.appropriate_body.present? && @profile.ect?
  end
end
