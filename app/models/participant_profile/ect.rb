# frozen_string_literal: true

class ParticipantProfile::ECT < ParticipantProfile
  belongs_to :school_cohort, optional: true
  belongs_to :school
  belongs_to :cohort

  belongs_to :mentor_profile, class_name: "Mentor", optional: true
  has_one :mentor, through: :mentor_profile, source: :user

  belongs_to :core_induction_programme, optional: true

  def ect?
    true
  end

  def participant_type
    :ect
  end

  before_save do |profile|
    profile.school_cohort = SchoolCohort.find_by(school: profile.school, cohort: profile.cohort)
  end
end
