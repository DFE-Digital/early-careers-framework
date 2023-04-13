# frozen_string_literal: true

FactoryBot.define do
  factory :induction_record do
    induction_programme
    participant_profile { create(:ect_participant_profile) }
    schedule { create(:ecf_schedule) }
    start_date { Date.new(2021, 1, 9) }

    trait :future_start_date do
      start_date { 2.months.from_now }
    end

    trait :with_end_date do
      end_date { start_date + 1.year }
    end

    trait :future_end_date do
      end_date { 1.year.from_now }
    end

    trait :past_end_date do
      start_date { 15.months.ago }
      end_date { 2.months.ago }
    end

    trait(:ecf) { participant_profile { create(:ect_participant_profile) } } # FIXME: remove
    trait(:ect) { participant_profile { create(:ect_participant_profile) } }
    trait(:mentor) { participant_profile { create(:mentor_participant_profile) } }

    trait(:active) { induction_status { "active" } }
    trait(:withdrawn) { induction_status { "withdrawn" } }
    trait(:leaving) { induction_status { "leaving" } }

    trait(:school_transfer) { school_transfer { true } }
    trait(:not_school_transfer) { school_transfer { false } }

    trait :preferred_identity do
      preferred_identity { create(:participant_identity) }
    end
  end
end
