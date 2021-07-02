# frozen_string_literal: true

class ProfileDeclaration < ApplicationRecord
  delegated_type :declarable, types: %w[EarlyCareerTeacherProfile MentorProfile]
  belongs_to :participant_declaration

  scope :uplift, lambda {
                   joins(
                     "left join early_career_teacher_profiles
                      on declarable_type='EarlyCareerTeacherProfile'
                      and declarable_id=early_career_teacher_profiles.id",
                   ).merge(EarlyCareerTeacherProfile.uplift)
                 }
end
