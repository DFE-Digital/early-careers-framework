# frozen_string_literal: true

class Schools::ParticipantsController < Schools::BaseController
  before_action :set_school_cohort
  before_action :set_participant, except: :index
  before_action :check_feature_flag

  def index
    @participants = User.order(:full_name).is_participant.in_school(@school.id)

    if @participants.empty?
      redirect_to add_schools_cohort_participants_path
    end

    authorize @participants, policy_class: ParticipantPolicy
  end

  def show
    @mentor = @participant.early_career_teacher_profile&.mentor
  end

  def edit_mentor
    @mentor_form = ParticipantMentorForm.new(
      mentor_id: @participant.early_career_teacher_profile.mentor&.id,
      school_id: @school.id,
    )
  end

  def update_mentor
    @mentor_form = ParticipantMentorForm.new(participant_mentor_form_params.merge(school_id: @school.id))

    if @mentor_form.valid?
      @participant.early_career_teacher_profile.update!(mentor_profile: @mentor_form.mentor ? @mentor_form.mentor.mentor_profile : nil)

      flash[:success] = { title: "Success", heading: "The mentor for this participant has been updated" }
      redirect_to schools_cohort_participant_path(@cohort.start_year, @participant)
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
end
