# frozen_string_literal: true

module NewSupplierHelper
  # rubocop:disable Naming/MethodName
  def when_I_choose_a_supplier_name(name)
    get "/admin/suppliers/new"
    post "/admin/suppliers/new", params: { new_supplier_form: { name: name } }
  end

  alias_method :given_I_have_chosen_supplier_name, :when_I_choose_a_supplier_name

  def when_I_choose_a_delivery_partner_type
    get "/admin/suppliers/new/supplier-type"
    post "/admin/suppliers/new/supplier-type", params: { new_supplier_form: { type: "delivery_partner" } }
  end

  alias_method :given_I_have_chosen_delivery_partner_type, :when_I_choose_a_delivery_partner_type

  def when_I_choose_a_lead_provider_type
    get "/admin/suppliers/new/supplier-type"
    post "/admin/suppliers/new/supplier-type", params: { new_supplier_form: { type: "lead_provider" } }
  end

  alias_method :given_I_have_chosen_lead_provider_type, :when_I_choose_a_lead_provider_type

  def when_I_choose_a_cip(cip)
    get "/admin/suppliers/new/lead-provider/choose-cip"
    post "/admin/suppliers/new/lead-provider/choose-cip", params: { lead_provider_form: { cip: cip.id } }
  end

  alias_method :given_I_have_chosen_cip, :when_I_choose_a_cip

  def when_I_choose_cohorts(cohorts)
    get "/admin/suppliers/new/lead-provider/choose-cohorts"
    post "/admin/suppliers/new/lead-provider/choose-cohorts", params: { lead_provider_form: { cohorts: cohorts.map(&:id) } }
  end

  alias_method :given_I_have_chosen_cohorts, :when_I_choose_cohorts

  def when_I_choose_lps_and_cohorts(lead_providers, cohorts)
    get "/admin/suppliers/new/delivery-partner/choose-lps"
    post "/admin/suppliers/new/delivery-partner/choose-lps", params: { delivery_partner_form: {
      lead_providers: lead_providers.map(&:id),
      provider_relationship_hashes: cohorts.flat_map do |lead_provider, lp_cohorts|
        lp_cohorts.map { |cohort| DeliveryPartnerForm.provider_relationship_value(lead_provider, cohort) }
      end,
    } }
  end

  alias_method :given_I_have_chosen_lps_and_cohorts, :when_I_choose_lps_and_cohorts

  def when_I_confirm_my_choices
    post "/admin/suppliers/new/delivery-partner", params: {}
  end

  alias_method :given_I_have_confirmed_my_choices, :when_I_confirm_my_choices

  def when_I_confirm_my_lead_provider_choices
    post "/admin/suppliers/new/lead-provider", params: {}
  end

  alias_method :given_I_have_confirmed_my_lead_provider_choices, :when_I_confirm_my_lead_provider_choices
  # rubocop:enable Naming/MethodName
end
