# frozen_string_literal: true

module FinanceHelper
  include ActionView::Helpers::NumberHelper

  def number_to_pounds(number)
    number = 0 if number.zero?

    number_to_currency number, precision: 2, unit: "£"
  end

  def float_to_percentage(number)
    number_to_percentage(number * 100, precision: 0)
  end

  def change_induction_record_training_status_button(induction_record, participant_profile, row)
    if induction_record.cpd_lead_provider.present? &&
        induction_record == participant_profile.latest_induction_record_for(cpd_lead_provider: induction_record.cpd_lead_provider)

      row.action(
        text: "Change",
        visually_hidden_text: "training status",
        href: new_finance_participant_profile_ecf_induction_records_path(participant_profile.id, induction_record.id),
      )
    else
      row.action(text: :none)
    end
  end
end
