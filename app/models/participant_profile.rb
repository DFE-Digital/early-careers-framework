# frozen_string_literal: true

class ParticipantProfile < ApplicationRecord
  belongs_to :user
  belongs_to :school, optional: true

  enum status: {
    active: "active",
    withdrawn: "withdrawn",
  }

  scope :mentors, -> { where(type: Mentor.name) }
  scope :ects, -> { where(type: ECT.name) }

  scope :sparsity, -> { where(sparsity_uplift: true) }
  scope :pupil_premium, -> { where(pupil_premium_uplift: true) }
  scope :uplift, -> { sparsity.or(pupil_premium) }

  attr_reader :participant_type

  def ect?
    false
  end

  def mentor?
    false
  end

  def npq?
    false
  end

  scope :mentors, -> { where(type: Mentor.name) }
  scope :ects, -> { where(type: ECT.name) }
  scope :npqs, -> { where(type: NPQ.name) }
  scope :ecf, -> { where(type: [ECT.name, Mentor.name]) }

  scope :sparsity, -> { where(sparsity_uplift: true) }
  scope :pupil_premium, -> { where(pupil_premium_uplift: true) }
  scope :uplift, -> { sparsity.or(pupil_premium) }
end
