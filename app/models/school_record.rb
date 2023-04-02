# frozen_string_literal: true

class SchoolRecord < ApplicationRecord
  has_paper_trail

  # Associations
  belongs_to :school
  belongs_to :participant_profile, class_name: "ParticipantProfile::ECF", touch: true
  belongs_to :joining_induction_record, class_name: "InductionRecord"
  belongs_to :leaving_induction_record, class_name: "InductionRecord", optional: true

  # Validations
  validates :joining_date, presence: true
end
