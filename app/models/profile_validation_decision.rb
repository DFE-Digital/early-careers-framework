# frozen_string_literal: true

class ProfileValidationDecision < ApplicationRecord
  has_paper_trail

  validates :note, presence: true
  validates :approved, inclusion: { in: [true, false] }
end
