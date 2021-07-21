# frozen_string_literal: true

class ParticipantProfile < ApplicationRecord
  class Mentor < Ecf
    self.ignored_columns = %i[mentor_profile_id school_id]

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
end
