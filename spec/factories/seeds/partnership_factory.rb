# frozen_string_literal: true

FactoryBot.define do
  factory(:seed_partnership, class: "Partnership") do
    challenge_deadline { cohort.academic_year_start_date + 2.months if cohort }

    trait(:with_cohort) { association(:cohort, factory: :seed_cohort) }
    trait(:with_school) { association(:school, factory: :seed_school) }
    trait(:with_lead_provider) { association(:lead_provider, factory: :seed_lead_provider) }
    trait(:with_delivery_partner) { association(:delivery_partner, factory: :seed_delivery_partner) }

    trait(:challenged) do
      challenged_at { 2.weeks.ago }
      challenge_reason { Partnership.challenge_reasons.keys.sample }
    end

    trait(:pending) { pending { true } }
    trait(:relationship) { relationship { true } }

    trait(:valid) do
      with_cohort
      with_school
      with_delivery_partner
      with_lead_provider
    end

    after(:build) do |partnership|
      provider_relationship_attrs = { cohort: partnership.cohort, lead_provider: partnership.lead_provider, delivery_partner: partnership.delivery_partner }
      if provider_relationship_attrs.values.all?(&:present?) && !ProviderRelationship.where(provider_relationship_attrs).exists?
        create(:provider_relationship, provider_relationship_attrs)
      end

      if partnership.school && partnership.lead_provider
        Rails.logger.debug(<<~MSG)
          seeded partnership between #{partnership.school.name} and lead provider #{partnership.lead_provider.name} with delivery partner #{partnership.delivery_partner.name}
        MSG
      else
        Rails.logger.debug("seeded incomplete partnership")
      end
    end
  end
end
