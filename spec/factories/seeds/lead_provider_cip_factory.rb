# frozen_string_literal: true

FactoryBot.define do
  factory(:seed_lead_provider_cip, class: "LeadProviderCip") do
    trait(:with_lead_provider) { association(:lead_provider, factory: :seed_lead_provider) }
    trait(:with_core_induction_programme) { association(:core_induction_programme, factory: :seed_core_induction_programme) }
    trait(:with_cohort) { Cohort.current }

    trait(:valid) do
      with_cohort
      with_lead_provider
      with_core_induction_programme
    end

    after(:build) do |lpc|
      msg = ["seeded lead provider"]

      if lpc.lead_provider.present?
        msg << "with lead provider #{lpc.lead_provider.name}"
      end

      if lpc.cohort.present?
        msg << "with start year #{lpc.cohort.start_year}"
      end

      if lpc.cohort.present?
        msg << "with core induction programme #{lpc.core_induction_programme.name}"
      end

      Rails.logger.debug(msg.join(", "))
    end
  end
end
