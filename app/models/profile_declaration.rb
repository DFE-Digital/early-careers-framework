# frozen_string_literal: true

class ProfileDeclaration < ApplicationRecord
  delegated_type :declarable, types: %w[EarlyCareerTeacherProfileDeclaration MentorProfileDeclaration]
  belongs_to :participant_declaration
  belongs_to :lead_provider

  scope :ect_profiles, lambda {
                         joins(
                           "left join early_career_teacher_profile_declarations
       on declarable_type='EarlyCareerTeacherProfileDeclaration'
       and declarable_id=early_career_teacher_profile_declarations.id
    left join early_career_teacher_profiles
       on early_career_teacher_profile_declarations.early_career_teacher_profile_id = early_career_teacher_profiles.id",
                         )
                       }
  scope :mentor_profiles, lambda {
                            joins(
                              "left join mentor_profile_declarations
  on declarable_type='MentorProfileDeclaration'
  and declarable_id=mentor_profile_declarations.id
  left join mentor_profiles on
  mentor_profile_declarations.mentor_profile_id = mentor_profiles.id",
                            )
                          }

  scope :uplift, -> { ect_profiles.mentor_profiles.merge(EarlyCareerTeacherProfile.uplift.or(merge(MentorProfile.uplift))) }
end
