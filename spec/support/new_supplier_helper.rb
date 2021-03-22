# frozen_string_literal: true

module NewSupplierHelper
  # rubocop:disable Naming/MethodName
  def when_I_choose_a_delivery_partner_name(name)
    get "/admin/suppliers/new/delivery-partner/choose-name"
    post "/admin/suppliers/new/delivery-partner/choose-name", params: { delivery_partner_form: { name: name } }
  end

  alias_method :given_I_have_chosen_delivery_partner_name, :when_I_choose_a_delivery_partner_name

  def when_I_choose_lps(lead_providers)
    get "/admin/suppliers/new/delivery-partner/choose-lps"
    post "/admin/suppliers/new/delivery-partner/choose-lps", params: { delivery_partner_form: {
      lead_provider_ids: lead_providers.map(&:id),
    } }
  end

  def when_I_choose_cohorts(cohorts)
    get "/admin/suppliers/new/delivery-partner/choose-cohorts"
    post "/admin/suppliers/new/delivery-partner/choose-cohorts", params: { delivery_partner_form: {
      provider_relationship_hashes: cohorts.flat_map do |lead_provider, lp_cohorts|
        lp_cohorts.map { |cohort| provider_relationship_value(lead_provider, cohort) }
      end,
    } }
  end

  def when_I_choose_lps_and_cohorts(lead_providers, cohorts)
    when_I_choose_lps(lead_providers)
    when_I_choose_cohorts(cohorts)
  end

  alias_method :given_I_have_chosen_lps_and_cohorts, :when_I_choose_lps_and_cohorts

  def when_I_confirm_my_choices
    post "/admin/suppliers/new/delivery-partner", params: {}
  end

  alias_method :given_I_have_confirmed_my_choices, :when_I_confirm_my_choices

  # rubocop:enable Naming/MethodName

  def provider_relationship_value(lead_provider, cohort)
    { "lead_provider_id" => lead_provider.id, "cohort_id" => cohort.id }.to_json
  end
end
