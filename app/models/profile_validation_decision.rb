# frozen_string_literal: true

class ProfileValidationDecision < ApplicationRecord
  has_paper_trail

  belongs_to :participant_profile

  validates :note, presence: true
  validates :approved, inclusion: { in: [true, false] }
end
