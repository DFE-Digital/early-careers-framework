# frozen_string_literal: true

class TrainingRecordState < ApplicationRecord
  belongs_to :participant_profile
  belongs_to :school, optional: true
  belongs_to :lead_provider, optional: true
  belongs_to :delivery_partner, optional: true
  belongs_to :appropriate_body, optional: true
end
