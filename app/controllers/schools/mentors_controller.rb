# frozen_string_literal: true

class Schools::MentorsController < Schools::BaseController
  before_action :set_school
  before_action :set_participant, only: %i[show]
  before_action :set_possible_ects, only: %i[show]
  before_action :set_mentors_added

  def index
    @participants = Dashboard::Participants.new(school: @school, user: current_user)
    @filter = Dashboard::Participants::Filter.new(
      dashboard_participants: @participants,
      filtered_by: params[:filtered_by],
      options: Dashboard::Participants::Filter::MENTOR_FILTER_OPTIONS,
    )
  end

  def show
    @induction_record = @profile.induction_records.for_school(@school).latest || @profile.latest_induction_record
    @first_induction_record = @profile.induction_records.oldest
    @mentor_profile = @induction_record.mentor_profile
    @ects = Dashboard::Participants.new(school: @school, user: current_user)
                                   .ects_mentored_by(@profile)
  end

private

  def set_mentors_added
    @mentors_added = @school.school_mentors.any?
  end

  def set_participant
    @profile = ParticipantProfile::Mentor.find(params[:participant_id] || params[:id])
    authorize @profile, policy_class: @profile.policy_class
    @induction_record = @profile.induction_records.for_school(@school).latest
  end

  def set_possible_ects
    return unless @profile.mentor?

    active_ects = Dashboard::Participants.new(school: @school, user: current_user, type: :early_career_teachers)
                                         .ects
                                         .sort_by(&:full_name)
                                         .map(&:induction_record)
    current_ects = InductionRecord.where(mentor_profile_id: @profile.id).to_a

    @possible_ects = active_ects - current_ects
  end
end
