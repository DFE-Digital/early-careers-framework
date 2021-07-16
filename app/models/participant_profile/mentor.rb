# frozen_string_literal: true

class ParticipantProfile::Mentor < ParticipantProfile
  self.ignored_columns = %i[mentor_profile_id]

  belongs_to :school_cohort
  has_one :school, through: :school_cohort
  has_one :cohort, through: :school_cohort

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
end
