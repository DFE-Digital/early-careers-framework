# frozen_string_literal: true

class NPQLeadProvider < ApplicationRecord
  belongs_to :cpd_lead_provider, optional: true

  has_many :npq_applications
  has_many :npq_participant_profiles, through: :npq_applications, source: :profile
  has_many :npq_participants, through: :npq_participant_profiles, source: :user

  has_many :npq_contracts
end
