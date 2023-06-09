# frozen_string_literal: true

class ParticipantProfile < ApplicationRecord
  class Mentor < ECF
    self.ignored_columns = %i[mentor_profile_id school_id]

    COURSE_IDENTIFIERS = %w[ecf-mentor].freeze

    has_many :mentee_profiles,
             class_name: "ParticipantProfile::ECT",
             foreign_key: :mentor_profile_id,
             dependent: :nullify
    has_many :mentees, through: :mentee_profiles, source: :user

    has_many :school_mentors, dependent: :destroy, foreign_key: :participant_profile_id
    has_many :schools, through: :school_mentors
    # TODO: causes a validation error, not sure why
    # has_many :participant_declarations

    def mentor?
      true
    end

    def participant_type
      :mentor
    end

    def role
      "Mentor"
    end
  end
end
