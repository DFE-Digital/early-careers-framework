# frozen_string_literal: true

class NpqLeadProvider < ApplicationRecord
  belongs_to :cpd_lead_provider, optional: true
end
