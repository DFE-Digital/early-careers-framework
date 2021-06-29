class ParticipantProfile < ApplicationRecord
  belongs_to :user
  belongs_to :school
  belongs_to :cohort
  belongs_to :core_induction_programme, optional: true

  def ect?
    false
  end

  def mentor?
    false
  end

  class ECT < self
    belongs_to :mentor_profile

    def ect?
      true
    end
  end

  class Mentor < self
    def mentor?
      true
    end
  end
end
