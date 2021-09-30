# frozen_string_literal: true

class NPQLeadProvider < ApplicationRecord
  belongs_to :cpd_lead_provider, optional: true

  has_many :npq_profiles, class_name: "NPQValidationData"
  has_many :npq_participants, through: :npq_profiles, source: :user
end
