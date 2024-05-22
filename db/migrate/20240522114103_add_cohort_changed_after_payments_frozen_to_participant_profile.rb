# frozen_string_literal: true

class AddCohortChangedAfterPaymentsFrozenToParticipantProfile < ActiveRecord::Migration[7.1]
  def change
    add_column :participant_profiles, :cohort_changed_after_payments_frozen, :boolean, default: false
  end
end
