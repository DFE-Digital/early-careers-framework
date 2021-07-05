# frozen_string_literal: true

class ProfileDeclaration < ApplicationRecord
  delegated_type :declarable, types: %w[EarlyCareerTeacherProfile MentorProfile]
  belongs_to :participant_declaration

  scope :ect_profiles, lambda {
    joins(
      "left join early_career_teacher_profiles
       on declarable_type='EarlyCareerTeacherProfile'
       and declarable_id=early_career_teacher_profiles.id",
    )
  }

  scope :mentor_profiles, lambda {
    joins(
      "left join mentor_profiles
       on declarable_type='MentorProfile'
       and declarable_id=mentor_profiles.id",
    )
  }

  scope :uplift, -> { ect_profiles.mentor_profiles.merge(EarlyCareerTeacherProfile.uplift.or(merge(MentorProfile.uplift))) }
end
