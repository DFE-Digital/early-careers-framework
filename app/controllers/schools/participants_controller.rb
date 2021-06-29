# frozen_string_literal: true

class Schools::ParticipantsController < Schools::BaseController
  before_action :set_school_cohort
  before_action :set_participant, except: :index
  before_action :check_feature_flag

  def index
    @participant_profiles = @school.participant_profiles.includes(:user).order("users.full_name")

    if @participant_profiles.empty?
      redirect_to add_schools_participants_path
    end

    authorize @participant_profiles, policy_class: ParticipantPolicy
  end

  def show
    @mentor_profile = @participant_profile.mentor_profile unless @participant_profile.mentor?
  end

  def edit_mentor
    @mentor_form = ParticipantMentorForm.new(
      mentor_id: @participant_profile.mentor_profile&.user_id,
      school_id: @school.id,
    )
  end

  def update_mentor
    @mentor_form = ParticipantMentorForm.new(participant_mentor_form_params.merge(school_id: @school.id))

    if @mentor_form.valid?
      @participant_profile.update!(mentor_profile: @mentor_form.mentor&.mentor_profile)

      flash[:success] = { title: "Success", heading: "The mentor for this participant has been updated" }
      redirect_to schools_participant_path(id: @participant_profile.user_id)
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
    @participant_profile = User.find(params[:participant_id] || params[:id]).participant_profile
    authorize @participant_profile, policy_class: ParticipantPolicy
  end

  def participant_mentor_form_params
    params.require(:participant_mentor_form).permit(:mentor_id)
  end
end
