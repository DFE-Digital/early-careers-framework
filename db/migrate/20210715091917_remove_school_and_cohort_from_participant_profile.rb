# frozen_string_literal: true

class ParticipantProfile < ApplicationRecord
  self.table_name = "participant_profiles"
end

class ParticipantProfile::Mentor < ParticipantProfile
  belongs_to :school_cohort, optional: true
  belongs_to :school, optional: true
  belongs_to :cohort, optional: true
end

class ParticipantProfile::ECT < ParticipantProfile
  belongs_to :school_cohort, optional: true
  belongs_to :school, optional: true
  belongs_to :cohort, optional: true
end

class ParticipantProfile::NPQ < ParticipantProfile
  belongs_to :school_cohort, optional: true
  belongs_to :school, optional: true
  belongs_to :cohort, optional: true
end

class RemoveSchoolAndCohortFromParticipantProfile < ActiveRecord::Migration[6.1]
  def up
    safety_assured do
      remove_reference :participant_profiles, :school
      remove_reference :participant_profiles, :cohort
    end
  end

  def down
    add_reference :participant_profiles, :school, foreign_key: true, index: true, null: true
    add_reference :participant_profiles, :cohort, foreign_key: true, index: true, null: true

    ParticipantProfile.all.each do |participant_profile|
      school_cohort = participant_profile.school_cohort
      participant_profile.update!(school: school_cohort.school, cohort: school_cohort.cohort)
    end
  end
end
