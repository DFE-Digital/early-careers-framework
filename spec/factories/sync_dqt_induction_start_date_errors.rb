# frozen_string_literal: true

FactoryBot.define do
  factory :sync_dqt_induction_start_date_error, class: SyncDQTInductionStartDateError do
    association :participant_profile, factory: :ect_participant_profile

    message { "sync failed!" }
  end
end
