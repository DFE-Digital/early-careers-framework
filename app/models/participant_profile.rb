# frozen_string_literal: true

class ParticipantProfile < ApplicationRecord
  belongs_to :user
  belongs_to :school
  belongs_to :cohort
  belongs_to :core_induction_programme, optional: true

  scope :mentors, -> { where(type: Mentor.name) }
  scope :ects, -> { where(type: ECT.name) }

  scope :sparsity, -> { where(sparsity_uplift: true) }
  scope :pupil_premium, -> { where(pupil_premium_uplift: true) }
  scope :uplift, -> { sparsity.or(pupil_premium) }

  attr_reader :participant_type

  def ect?
    false
  end

  def mentor?
    false
  end

  class ECT < self
    @participant_type = :ect
    belongs_to :mentor_profile, class_name: "Mentor", optional: true
    has_one :mentor, through: :mentor_profile, source: :user

    def ect?
      true
    end

    def participant_type
      :ect
    end
  end

  class Mentor < self
    @participant_type = :mentor

    self.ignored_columns = %i[mentor_profile_id]

    has_many :mentee_profiles,
             class_name: "ParticipantProfile::ECT",
             foreign_key: :mentor_profile_id,
             dependent: :nullify
    has_many :mentees, through: :mentee_profiles, source: :user

    def mentor?
      true
    end

    def participant_type
      :mentor
    end
  end
end
