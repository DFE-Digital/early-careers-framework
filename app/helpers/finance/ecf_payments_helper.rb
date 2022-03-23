# frozen_string_literal: true

module Finance
  module ECFPaymentsHelper
    def number_to_pounds(number)
      number_to_currency number, precision: 2, unit: "£"
    end

    def float_to_percentage(number)
      number_to_percentage(number * 100, precision: 0)
    end

    def aggregated_payment(breakdown_array)
      breakdown_array.map { |breakdown|
        breakdown[:service_fees][:monthly] + breakdown[:output_payments][:subtotal]
      }.inject(0, &:+)
    end

    # TODO: The VAT flag is set on the ECF lead_provider and not on the cpd_lead_provider table. Once someone is VAT
    # registered, then it shouldn't matter if they're one, the other or both. VAT should apply evenly. Needs to be
    # moved and migrated from LeadProvider to CPDLeadProvider.
    def aggregated_vat(breakdown_array, _lead_provider)
      aggregated_payment(breakdown_array) * 0.2
    end

    def total_payment_with_vat_combined(breakdown_started, breakdown_retained_1, lead_provider)
      total_payment_combined(breakdown_started, breakdown_retained_1) + total_vat_combined(breakdown_started, breakdown_retained_1, lead_provider)
    end

    def total_vat_combined(breakdown_started, breakdown_retained_1, lead_provider)
      total_payment_combined(breakdown_started, breakdown_retained_1) * (lead_provider.vat_chargeable ? 0.2 : 0.0)
    end

    def total_payment_combined(breakdown_started, breakdown_retained_1)
      service_fee = breakdown_started[:service_fees].map { |params| params[:monthly] }.sum
      output_payment = breakdown_started[:output_payments].map { |params| params[:subtotal] }.sum
      other_fees = breakdown_started[:other_fees].values.map { |other_fee| other_fee[:subtotal] }.sum
      retained_output_payment = breakdown_retained_1[:output_payments].map { |params| params[:subtotal] }.sum

      service_fee + output_payment + other_fees + retained_output_payment
    end

    def total_payment(breakdown)
      service_fee = breakdown[:service_fees].map { |params| params[:monthly] }.sum
      output_payment = breakdown[:output_payments].map { |params| params[:subtotal] }.sum
      other_fees  =
        if breakdown[:other_fees]
          breakdown[:other_fees].values.map { |other_fee| other_fee[:subtotal] }.sum
        else
          0
        end

      service_fee + output_payment + other_fees
    end
  end
end
