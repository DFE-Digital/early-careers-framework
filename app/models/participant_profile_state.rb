# frozen_string_literal: true

class ParticipantProfileState < ApplicationRecord
  belongs_to :participant_profile, touch: true
  belongs_to :cpd_lead_provider, optional: true

  enum state: {
    active: "active",
    deferred: "deferred",
    withdrawn: "withdrawn",
  }

  scope :most_recent, -> { order("created_at desc").limit(1) }
  scope :withdrawn, -> { where(state: states[:withdrawn]) }
  scope :deferred, -> { where(state: states[:deferred]) }
  scope :for_lead_provider, ->(cpd_lead_provider) { where(cpd_lead_provider:) }

  # Return new reason type if feature is on
  def reason
    val = self[:reason]

    if FeatureFlag.active?(:new_programme_types) && val == "school-left-fip"
      val = "school-left-provider-led"
    end

    val
  end
end
