# frozen_string_literal: true

class TeacherProfile < ApplicationRecord
  belongs_to :user, touch: true
  belongs_to :school, optional: true

  has_many :participant_profiles, dependent: :destroy

  # TODO: Legacy associations, to be removed
  has_one :early_career_teacher_profile, -> { ects.active_record }, class_name: "ParticipantProfile"
  has_one :mentor_profile, -> { mentors.active_record }, class_name: "ParticipantProfile"
  has_one :ecf_profile, -> { ecf.active_record }, class_name: "ParticipantProfile"

  has_many :npq_profiles, class_name: "ParticipantProfile::NPQ"
  # end: TODO
end
