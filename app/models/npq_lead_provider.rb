# frozen_string_literal: true

class NPQLeadProvider < ApplicationRecord
  belongs_to :cpd_lead_provider, optional: true

  has_many :npq_profiles, class_name: "NPQValidationData"
end
