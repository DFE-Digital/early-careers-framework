# frozen_string_literal: true

require "rails_helper"

RSpec.describe Niot do
  describe ".lead_provider" do
    subject { Niot.lead_provider }

    context "when there is a lead provider with name 'National Institute of Teaching'" do
      let!(:niot) { create(:lead_provider, name: "National Institute of Teaching") }

      it { is_expected.to eq(niot) }
    end

    context "when there isn't a lead provider with name 'National Institute of Teaching'" do
      before do
        create(:lead_provider, name: "Ambition Institute")
      end

      it { is_expected.to be_nil }
    end
  end
end
