# frozen_string_literal: true

class ParticipantProfile::Mentor < ParticipantProfile
  self.ignored_columns = %i[mentor_profile_id]

  belongs_to :school_cohort, optional: true
  belongs_to :school
  belongs_to :cohort

  has_many :mentee_profiles,
           class_name: "ParticipantProfile::ECT",
           foreign_key: :mentor_profile_id,
           dependent: :nullify
  has_many :mentees, through: :mentee_profiles, source: :user

  belongs_to :core_induction_programme, optional: true

  def mentor?
    true
  end

  def participant_type
    :mentor
  end

  before_save do |profile|
    profile.school_cohort = SchoolCohort.find_by(school: profile.school, cohort: profile.cohort)
  end
end
