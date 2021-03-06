# frozen_string_literal: true

class NPQValidationData < ApplicationRecord
  # TODO: Rename table
  self.table_name = "npq_profiles"

  has_one :profile, class_name: "ParticipantProfile::NPQ", foreign_key: :id
  belongs_to :user
  belongs_to :npq_lead_provider
  belongs_to :npq_course

  enum headteacher_status: {
    no: "no",
    yes_when_course_starts: "yes_when_course_starts",
    yes_in_first_two_years: "yes_in_first_two_years",
    yes_over_two_years: "yes_over_two_years",
  }

  enum funding_choice: {
    school: "school",
    trust: "trust",
    self: "self",
    another: "another",
  }

  after_save :update_participant_profile

private

  def update_participant_profile
    profile = ParticipantProfile::NPQ.find_or_initialize_by(id: id)
    profile.school = School.find_by(urn: school_urn)
    profile.user_id = user_id
    profile.save!
  end
end
