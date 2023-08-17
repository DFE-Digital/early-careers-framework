# frozen_string_literal: true

module FinanceHelper
  include ActionView::Helpers::NumberHelper
  include CodeHighlightHelper

  def number_to_pounds(number)
    number = 0 if number.zero?

    number_to_currency number, precision: 2, unit: "£"
  end

  def float_to_percentage(number)
    number_to_percentage(number * 100, precision: 0)
  end

  def change_induction_record_training_status_button(induction_record, participant_profile, row)
    if latest_induction_record_for_provider?(induction_record, participant_profile)
      row.with_action(
        text: "Change",
        visually_hidden_text: "training status",
        href: new_finance_participant_profile_ecf_induction_records_path(participant_profile.id, induction_record.id),
      )
    else
      row.with_action(text: :none)
    end
  end

  def npq_participant_api_response(participant_profile)
    cpd_lead_provider = participant_profile.npq_application&.npq_lead_provider&.cpd_lead_provider
    serializer_output = Api::V3::NPQParticipantSerializer.new(participant_profile.user, params: { cpd_lead_provider: }).serializable_hash
    highlight_as_json(serializer_output)
  end

  def induction_record_participant_api_response(induction_record, participant_profile)
    cpd_lead_provider = induction_record.induction_programme.partnership&.lead_provider&.cpd_lead_provider
    serializer_output = Api::V3::ECF::ParticipantSerializer.new(participant_profile.user, params: { cpd_lead_provider: }).serializable_hash
    highlight_as_json(serializer_output)
  end

  def npq_application_api_response(npq_application)
    serializer_output = Api::V3::NPQApplicationSerializer.new(npq_application).serializable_hash
    highlight_as_json(serializer_output)
  end

  def latest_induction_record_for_provider?(induction_record, participant_profile)
    cpd_lead_provider = induction_record.cpd_lead_provider

    return false unless cpd_lead_provider

    induction_record == participant_profile.latest_induction_record_for(cpd_lead_provider:)
  end
end
