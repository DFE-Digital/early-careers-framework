# frozen_string_literal: true

FactoryBot.define do
  factory :participant_id_change do
    user { create(:user) }
    from_participant { create(:user) }
    to_participant { create(:user) }
  end
end
