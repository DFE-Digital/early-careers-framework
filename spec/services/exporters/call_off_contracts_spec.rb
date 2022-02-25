# frozen_string_literal: true

require "rails_helper"

RSpec.describe Exporters::CallOffContracts do
  let(:contract) { create(:call_off_contract) }

  describe "#call" do
    it "outputs headers" do
      expect { subject.call }.to output(/version,uplift_target,uplift_amount,recruitment_target,set_up_fee,revised_target,lead_provider_name/).to_stdout
    end

    it "outputs data" do
      expect { subject.call }.to output(/#{contract.version},#{contract.uplift_target},#{contract.uplift_amount},#{contract.recruitment_target},#{contract.set_up_fee},#{contract.revised_target},#{contract.lead_provider.name}/).to_stdout
    end
  end
end
