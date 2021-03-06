# frozen_string_literal: true

FactoryBot.define do
  factory :induction_coordinator_profile do
    user
    schools { [build(:school, name: "East Deckow")] }
  end
end
