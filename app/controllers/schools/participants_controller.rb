# frozen_string_literal: true

class Schools::ParticipantsController < Schools::BaseController
  before_action :set_school_cohort
  before_action :set_participant, except: %i[index email_used]
  before_action :check_feature_flag

  def index
    @participants = @school_cohort.active_participants.order(:full_name)

    if @participants.empty?
      redirect_to add_schools_participants_path
    end

    authorize @participants, policy_class: ParticipantPolicy
  end

  def show
    @mentor = @participant.early_career_teacher_profile&.mentor
  end

  def edit_name; end

  def update_name
    if @participant.update(params.require(:user).permit(:full_name))
      if @participant.early_career_teacher?
        set_success_message(heading: "The ECT’s name has been updated")
      else
        set_success_message(heading: "The mentor’s name has been updated")
      end
      redirect_to schools_participant_path(id: @participant)
    else
      render "schools/participants/edit_name"
    end
  end

  def edit_email; end

  def update_email
    @participant.assign_attributes(params.require(:user).permit(:email))
    redirect_to action: :email_used and return if email_used?

    if @participant.save
      if @participant.early_career_teacher?
        set_success_message(heading: "The ECT’s email address has been updated")
      else
        set_success_message(heading: "The mentor’s email address has been updated")
      end
      redirect_to schools_participant_path(id: @participant)
    else
      render "schools/participants/edit_email"
    end
  end

  def email_used; end

  def edit_mentor
    @mentor_form = ParticipantMentorForm.new(
      mentor_id: @participant.early_career_teacher_profile.mentor&.id,
      school_id: @school.id,
      cohort_id: @cohort.id,
    )
  end

  def update_mentor
    @mentor_form = ParticipantMentorForm.new(participant_mentor_form_params.merge(school_id: @school.id, cohort_id: @cohort.id))

    if @mentor_form.valid?
      @participant.early_career_teacher_profile.update!(mentor_profile: @mentor_form.mentor ? @mentor_form.mentor.mentor_profile : nil)

      flash[:success] = { title: "Success", heading: "The mentor for this participant has been updated" }
      redirect_to schools_participant_path(id: @participant)
    else
      render :edit_mentor
    end
  end

private

  def check_feature_flag
    return if FeatureFlag.active?(:induction_tutor_manage_participants, for: @school)

    raise ActionController::RoutingError, "Not enabled for this school"
  end

  def set_participant
    @participant = User.find(params[:participant_id] || params[:id])
    authorize @participant, policy_class: ParticipantPolicy
  end

  def participant_mentor_form_params
    params.require(:participant_mentor_form).permit(:mentor_id)
  end

  def email_used?
    User.where.not(id: @participant.id).where(email: @participant.email).any?
  end
end
