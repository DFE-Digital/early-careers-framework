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

class PopulateSchoolCohortOnProfile < ActiveRecord::Migration[6.1]
  def up
    ParticipantProfile.ecf.all.each do |participant_profile|
      school_cohort = SchoolCohort.find_by(school: participant_profile.school, cohort: participant_profile.cohort)
      participant_profile.update!(school_cohort: school_cohort)
    end
  end
end
