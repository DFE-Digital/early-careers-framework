# frozen_string_literal: true

require "rails_helper"

RSpec.describe Exporters::NPQContracts do
  let(:contract) { create(:npq_contract) }

  describe "#call" do
    it "outputs headers" do
      expect { subject.call }.to output(/version,npq_lead_provider_name,recruitment_target,course_identifier,service_fee_installments,service_fee_percentage,per_participant,number_of_payment_periods,output_payment_percentage/).to_stdout
    end

    it "outputs data" do
      expected = [
        contract.version,
        contract.npq_lead_provider.name,
        contract.recruitment_target,
        contract.course_identifier,
        contract.service_fee_installments,
        contract.service_fee_percentage,
        contract.per_participant,
        contract.number_of_payment_periods,
        contract.output_payment_percentage,
      ].join(",")

      expect { subject.call }.to output(/#{expected}/).to_stdout
    end
  end
end
