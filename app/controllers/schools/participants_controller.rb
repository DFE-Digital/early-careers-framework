# frozen_string_literal: true

class Schools::ParticipantsController < Schools::BaseController
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  before_action :set_school_and_cohort
  before_action :set_participant, except: :index

  def index
    @participants = User.order(:full_name).is_participant.in_school(@school.id)
  end

  def show
    @mentor = @participant.early_career_teacher_profile&.mentor
  end

  def edit_details; end

  def edit_mentor
    @mentor_form = ParticipantForm.new(
      mentor_id: @participant.early_career_teacher_profile.mentor&.id,
    )

    @mentors = @school.mentors.order(:full_name)
  end

  def update
    @mentor_form = ParticipantForm.new(participant_form_params)

    # mentor_id can be nil
    if @mentor_form.mentor_id
      mentor = @mentor_form.mentor_id != "later" && User.find(@mentor_form.mentor_id)

      if mentor && @school.mentors.exclude?(mentor)
        raise Pundit::NotAuthorizedError, "No access to this mentor"
      end

      @participant.early_career_teacher_profile.update!(mentor_profile: mentor ? mentor.mentor_profile : nil)

      flash[:success] = { title: "Success", heading: "The mentor for this participant has been updated" }
      redirect_to schools_cohort_participant_path(@cohort.start_year, @participant)
    end
  end

private

  def set_school_and_cohort
    @school = current_user.induction_coordinator_profile.schools.first
    @cohort = Cohort.find_by(start_year: params[:cohort_id])
  end

  def set_participant
    @participant = User.is_participant.in_school(@school.id).find(params[:participant_id] || params[:id])
  end

  def participant_form_params
    params.require(:participant_form).permit(:full_name, :email, :mentor_id)
  end
end
