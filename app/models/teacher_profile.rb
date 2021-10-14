# frozen_string_literal: true

class TeacherProfile < ApplicationRecord
  belongs_to :user, touch: true
  belongs_to :school, optional: true

  has_many :participant_profiles, dependent: :destroy

  # TODO: Legacy associations, to be removed
  has_one :early_career_teacher_profile, -> { active_record }, class_name: "ParticipantProfile::ECT"
  has_one :mentor_profile, -> { active_record }, class_name: "ParticipantProfile::Mentor"

  has_many :ecf_profiles, -> { active_record.includes(:cohort).order("cohort.start_year DESC") }, class_name: "ParticipantProfile::ECF"
  has_one :ecf_profile_2020, -> { active_record.includes(:cohort).where(cohort: { start_year: 2020 }) }, class_name: "ParticipantProfile::ECF"
  has_one :ecf_profile_2021, -> { active_record.includes(:cohort).where(cohort: { start_year: 2021 }) }, class_name: "ParticipantProfile::ECF"

  has_many :npq_profiles, class_name: "ParticipantProfile::NPQ"
  # end: TODO
end
