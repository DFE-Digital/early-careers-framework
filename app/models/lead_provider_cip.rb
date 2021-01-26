# frozen_string_literal: true

class LeadProviderCip < ApplicationRecord
  belongs_to :lead_provider
  belongs_to :cohort
  belongs_to :core_induction_programme
end
