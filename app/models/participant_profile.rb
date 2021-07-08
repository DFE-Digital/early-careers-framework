# frozen_string_literal: true

class ParticipantProfile < ApplicationRecord
  belongs_to :user

  enum status: {
    active: "active",
    withdrawn: "withdrawn",
  }

  def ect?
    false
  end

  def mentor?
    false
  end

  scope :mentors, -> { where(type: Mentor.name) }
  scope :ects, -> { where(type: ECT.name) }

  scope :sparsity, -> { where(sparsity_uplift: true) }
  scope :pupil_premium, -> { where(pupil_premium_uplift: true) }
  scope :uplift, -> { sparsity.or(pupil_premium) }
end
