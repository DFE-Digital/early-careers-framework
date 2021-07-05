# frozen_string_literal: true

class MentorProfile < ApplicationRecord
  has_paper_trail

  belongs_to :user
  belongs_to :school
  belongs_to :core_induction_programme, optional: true
  belongs_to :cohort, optional: true
  has_many :early_career_teacher_profiles
  has_many :early_career_teachers, through: :early_career_teacher_profiles, source: :user
  has_many :profile_declarations

  scope :sparsity, -> { where(sparsity_uplift: true) }
  scope :pupil_premium, -> { where(pupil_premium_uplift: true) }
  scope :uplift, -> { sparsity.or(pupil_premium) }
  # TODO: Add a link to participant_record if we need to

  after_save :save_participant_profile
  before_destroy :destroy_participant_profile

private

  def save_participant_profile
    profile = ParticipantProfile::Mentor.find_or_initialize_by(id: id)
    profile.assign_attributes(attributes)
    profile.save!
  end

  def destroy_participant_profile
    ParticipantProfile::Mentor.where(id: id).destroy_all
  end
end
