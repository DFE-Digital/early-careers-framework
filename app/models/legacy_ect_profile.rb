# frozen_string_literal: true

class LegacyECTeacherProfile < ApplicationRecord
  self.table_name = "early_career_teacher_profiles"
  has_paper_trail

  belongs_to :user
  belongs_to :school
  belongs_to :core_induction_programme, optional: true
  belongs_to :cohort
  belongs_to :mentor_profile, optional: true
  has_one :mentor, through: :mentor_profile, source: :user
  has_many :profile_declarations

  scope :sparsity, -> { where(sparsity_uplift: true) }
  scope :pupil_premium, -> { where(pupil_premium_uplift: true) }
  scope :uplift, -> { sparsity.or(pupil_premium) }

  after_save :save_participant_profile
  before_destroy :destroy_participant_profile

private

  def save_participant_profile
    profile = ParticipantProfile::ECT.find_or_initialize_by(id: id)
    profile.assign_attributes(attributes)
    profile.save!
  end

  def destroy_participant_profile
    ParticipantProfile::ECT.where(id: id).destroy_all
  end
end
