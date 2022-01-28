# frozen_string_literal: true

class InductionRecord < ApplicationRecord
  has_paper_trail

  belongs_to :induction_programme
  belongs_to :participant_profile
  belongs_to :schedule, class_name: "Finance::Schedule"

  validates :start_date, presence: true
end
