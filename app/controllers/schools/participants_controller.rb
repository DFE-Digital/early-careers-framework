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
      @categories = CocSetParticipantCategories.new(@school_cohort, current_user)
    else
      @categories = OpenStruct.new(
        ect_categories: SetParticipantCategories.call(@school_cohort, current_user, ParticipantProfile::ECT),
        mentor_categories: SetParticipantCategories.call(@school_cohort, current_user, ParticipantProfile::Mentor),
        transferred: [],
        transferring_in: [],
        transferring_out: [],
      )
      @categories.withdrawn = @categories.ect_categories.withdrawn + @categories.mentor_categories.withdrawn
      @categories.ineligible = @categories.ect_categories.ineligible + @categories.mentor_categories.ineligible
    end
  end

  def show
    @induction_record = @profile.induction_records.for_school(@school).latest
    @first_induction_record = @profile.induction_records.oldest
    @mentor_profile = @induction_record.mentor_profile
  end

  def edit_name
    @reason = params[:reason].presence&.to_sym
    @selected_reason = params[:selected_reason].presence&.to_sym
    render helpers.edit_name_template(@reason)
  end

  def update_name
    @old_name = @profile.full_name

    if @profile.user.update(full_name: params[:full_name])
      render :update_name
    else
      @profile.user.full_name = @old_name
      render "schools/participants/edit_name"
    end
  end

  def edit_email; end

  def update_email
    identity = @induction_record.preferred_identity
    identity.assign_attributes(email: params[:email])
    redirect_to action: :email_used and return if email_used?(identity.email)

    render "schools/participants/edit_email" and return if identity.invalid?

    Induction::ChangePreferredEmail.call(induction_record: @induction_record,
                                         preferred_email: identity.email)
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

  def appropriate_body_confirmation; end

  def remove; end

  def destroy
    Induction::RemoveParticipantFromSchool.call(participant_profile: @profile,
                                                school: @school,
                                                sit_name: current_user.full_name)
    render :removed
  end

private

  def set_mentors_added
    @mentors_added = @school.school_mentors.any?
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
    super action_name: @induction_record.appropriate_body_id.present? ? :change : :add,
          from_path: schools_participant_path(id: @profile.id),
          submit_action: :save_appropriate_body,
          school_name: @profile.user.full_name,
          ask_appointed: false
  end

  def save_appropriate_body
    @induction_record.update!(appropriate_body_id: appropriate_body_form.body_id)

    redirect_to url_for(action: :appropriate_body_confirmation)
  end

  def participant_has_appropriate_body?
    @induction_record.appropriate_body.present?
  end

  def can_appropriate_body_be_changed?
    @school_cohort.appropriate_body.present? && @profile.ect?
  end
end
