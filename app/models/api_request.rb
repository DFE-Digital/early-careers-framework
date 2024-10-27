# frozen_string_literal: true

class ApiRequest < ApplicationRecord
  belongs_to :cpd_lead_provider, optional: true
  scope :unprocessable_entities, -> { where(status_code: 422) }
  scope :errors, -> { where.not(status_code: [200, 302, 301]) }
  scope :successful, -> { where(status_code: [200]) }
end
