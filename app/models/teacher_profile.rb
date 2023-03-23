# frozen_string_literal: true

class TeacherProfile < ApplicationRecord
  has_paper_trail
  belongs_to :user, touch: true
  belongs_to :school, optional: true

  has_many :participant_profiles, dependent: :destroy

  # TODO: Legacy associations, to be removed
  has_one :early_career_teacher_profile, -> { active_record }, class_name: "ParticipantProfile::ECT"
  has_one :current_ect_profile, -> { active_record.includes(:school_cohort).where(school_cohort: { cohort: Cohort.current }) }, class_name: "ParticipantProfile::ECT"
  has_one :mentor_profile, -> { active_record }, class_name: "ParticipantProfile::Mentor"

  has_many :ecf_profiles, -> { active_record.includes(school_cohort: :cohort).joins(school_cohort: :cohort).order("cohort.start_year DESC") }, class_name: "ParticipantProfile::ECF"
  has_one :current_ecf_profile, -> { active_record.includes(:school_cohort).where(school_cohort: { cohort: Cohort.active_registration_cohort }) }, class_name: "ParticipantProfile::ECF"

  has_many :npq_profiles, class_name: "ParticipantProfile::NPQ"
  # end: TODO

  self.filter_attributes += [:trn]

  def self.trn_matches(search_term)
    return none if search_term.blank?

    where("teacher_profiles.trn like ?", "%#{search_term}%")
  end
end
