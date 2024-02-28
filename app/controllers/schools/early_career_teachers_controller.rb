# frozen_string_literal: true

class Schools::EarlyCareerTeachersController < Schools::BaseController
  before_action :set_school
  before_action :set_mentors_added
  before_action :set_participant, only: %i[show]

  helper_method :can_appropriate_body_be_changed?, :participant_has_appropriate_body?

  def index
    @participants = Dashboard::Participants.new(school: @school, user: current_user)
    @filter = Dashboard::Participants::Filter.new(
      dashboard_participants: @participants,
      filtered_by: params[:filtered_by],
      options: Dashboard::Participants::Filter::ECT_FILTER_OPTIONS,
    )
  end

  def show
    @induction_record = @profile.induction_records.for_school(@school).latest || @profile.latest_induction_record
    @first_induction_record = @profile.induction_records.oldest
    @mentor_profile = @induction_record.mentor_profile
  end

private

  def set_participant
    @profile = ParticipantProfile::ECT.find(params[:participant_id] || params[:id])
    authorize @profile, policy_class: @profile.policy_class
    @induction_record = @profile.induction_records.for_school(@school).latest
  end

  def set_mentors_added
    @mentors_added = @school.school_mentors.any?
  end

  def participant_has_appropriate_body?
    @induction_record.appropriate_body.present?
  end

  def can_appropriate_body_be_changed?
    @profile.ect? && !@induction_record.training_status_withdrawn?
  end
end
