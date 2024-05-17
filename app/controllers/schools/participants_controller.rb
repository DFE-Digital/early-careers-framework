# frozen_string_literal: true

class Schools::ParticipantsController < Schools::BaseController
  include AppropriateBodySelection::Controller
  include Schools::DashboardHelper

  before_action :set_school
  before_action :set_participant, except: :email_used
  before_action :set_possible_ects, only: %i[show new_ect add_ect]
  before_action :build_mentor_form, only: :edit_mentor
  before_action :set_mentors_added, only: :show
  before_action :authorize_induction_record, only: %i[edit_name
                                                      update_name
                                                      edit_email
                                                      update_email
                                                      edit_mentor
                                                      update_mentor]
  before_action :authorize_ab_changes, only: %i[add_appropriate_body
                                                appropriate_body_confirmation]

  helper_method :can_appropriate_body_be_changed?, :participant_has_appropriate_body?

  # This page has been split into /schools/:school_id/early_career_teachers/:id and /schools/:school_id/mentors/:id
  # To preserve bookmarks I've added a redirect to the correct page.
  def show
    redirect_to path_to_participant(@profile, @school)
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
      track_validation_error(@profile.user)
      @profile.user.full_name = @old_name
      render "schools/participants/edit_name"
    end
  end

  def edit_email; end

  def update_email
    identity = @profile.user.participant_identities.find_by(email: params[:email]) || @induction_record.preferred_identity
    identity.assign_attributes(email: params[:email])
    redirect_to action: :email_used and return if email_used?(identity.email)

    if identity.invalid?
      track_validation_error(identity)
      render "schools/participants/edit_email"
      return
    end

    Induction::ChangePreferredEmail.call(induction_record: @induction_record,
                                         preferred_email: identity.email)
  end

  def email_used; end

  def new_ect; end

  def add_ect
    render(:new_ect) and return if params[:induction_record_id].blank?

    @ect_induction_record = InductionRecord.find(params[:induction_record_id])
    authorize(@ect_induction_record, :update_mentor?)
    Induction::ChangeMentor.call(induction_record: @ect_induction_record, mentor_profile: @profile)
    @message = "#{@profile.full_name} has been assigned to #{@ect_induction_record.participant_full_name}"

    redirect_to path_to_participant(@profile, @school)
  end

  def edit_mentor; end

  def update_mentor
    if params[:participant_mentor_form].blank?
      build_mentor_form
      @mentor_form.valid?
      render :edit_mentor and return
    end

    @mentor_form = ParticipantMentorForm.new(participant_mentor_form_params.merge(school_id: @school.id,
                                                                                  user: @profile.user))

    if @mentor_form.valid?
      induction_record = @profile.induction_records.for_school(@school).latest
      new_mentor_profile = @mentor_form.mentor&.mentor_profile
      if new_mentor_profile.id == induction_record.mentor_profile_id
        @message = "#{new_mentor_profile.full_name} still assigned to #{@profile.full_name}"
      else
        Induction::ChangeMentor.call(induction_record:, mentor_profile: new_mentor_profile)
        @message = "#{new_mentor_profile.full_name} has been assigned to #{@profile.full_name}"
      end

      redirect_to path_to_participant(@profile, @school)
    else
      track_validation_error(@mentor_form)
      render :edit_mentor
    end
  end

  def add_appropriate_body
    if can_appropriate_body_be_changed?
      start_appropriate_body_selection
    else
      redirect_to path_to_participant(@profile, @school)
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

  def authorize_ab_changes
    authorize @induction_record, :edit_appropriate_body?
  end

  def authorize_induction_record
    authorize @induction_record
  end

  def set_mentors_added
    @mentors_added = @school.school_mentors.any?
  end

  def build_mentor_form
    @mentor_form = ParticipantMentorForm.new(mentor_id: @profile.mentor&.id,
                                             school_id: @school.id,
                                             user: @profile.user)
  end

  def set_participant
    @profile = ParticipantProfile.find(params[:participant_id] || params[:id])
    authorize @profile, policy_class: @profile.policy_class
    @induction_record = @profile.induction_records.for_school(@school).latest
  end

  def set_possible_ects
    return unless @profile.mentor?

    active_ects = Dashboard::Participants.new(school: @school, user: current_user)
                                         .ects
                                         .sort_by(&:full_name)
                                         .map(&:induction_record)
    current_ects = InductionRecord.where(mentor_profile_id: @profile.id).to_a

    @possible_ects = active_ects - current_ects
  end

  def participant_mentor_form_params
    params.require(:participant_mentor_form).permit(:mentor_id)
  end

  def email_used?(email)
    User.where(email:).where.not(id: @profile.user.id).any? || ParticipantIdentity.where(email:).where.not(user_id: @profile.user.id).any?
  end

  def start_appropriate_body_selection
    super action_name: @induction_record.appropriate_body_id.present? ? :change : :add,
          from_path: path_to_participant(@profile, @school),
          submit_action: :save_appropriate_body,
          school: @school,
          ask_appointed: false,
          cohort_start_year: @induction_record.cohort_start_year
  end

  def save_appropriate_body
    @induction_record.update!(appropriate_body_id: appropriate_body_form.body_id)

    redirect_to url_for(action: :appropriate_body_confirmation)
  end

  def participant_has_appropriate_body?
    @induction_record.appropriate_body.present?
  end

  def can_appropriate_body_be_changed?
    @profile.ect? && !@induction_record.training_status_withdrawn?
  end
end
