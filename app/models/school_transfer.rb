# frozen_string_literal: true

class SchoolTransfer < ApplicationRecord
  has_paper_trail

  # Associations
  belongs_to :participant_profile, class_name: "ParticipantProfile::ECF", touch: true
  belongs_to :leaving_school, class_name: "School"
  belongs_to :joining_school, class_name: "School", optional: true
  belongs_to :leaving_provider, class_name: "LeadProvider"
  belongs_to :joining_provider, class_name: "LeadProvider", optional: true

  # Validations
  validates :leaving_date, presence: true
end
