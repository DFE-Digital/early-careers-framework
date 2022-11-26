# frozen_string_literal: true

FactoryBot.define do
  factory(:seed_partnership, class: "Partnership") do
    trait(:with_cohort) { cohort { Cohort.first } }
    trait(:with_school) { association(:school, factory: :seed_school) }
    trait(:with_lead_provider) { association(:lead_provider, factory: :seed_lead_provider) }
    trait(:with_delivery_partner) { association(:delivery_partner, factory: :seed_delivery_partner) }

    trait(:challenged) do
      challenged_at { 2.weeks.ago }
      challenge_reason { Partnership.challenge_reasons.keys.sample }
    end

    trait(:pending) { pending { true } }
    trait(:relationship) { relationship { true } }

    after(:build) do |p|
      Rails.logger.debug(<<~MSG)
        seeded partnership between #{p.school.name} and lead provider #{p.lead_provider.name} with delivery partner #{p.delivery_partner.name}
      MSG
    end
  end
end
