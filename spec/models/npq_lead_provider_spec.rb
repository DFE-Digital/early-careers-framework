# frozen_string_literal: true

require "rails_helper"

RSpec.describe NPQLeadProvider, type: :model do
  it "can be created" do
    expect {
      described_class.create(name: "Test Lead Provider")
    }.to change { described_class.count }.by(1)
  end

  describe "associations" do
    it { is_expected.to belong_to(:cpd_lead_provider).required(false) }
    it { is_expected.to have_many(:statements).through(:cpd_lead_provider).class_name("Finance::Statement::NPQ").source(:npq_statements) }
  end

  describe "scopes" do
    describe "name_order" do
      let!(:provider_one) { FactoryBot.create(:npq_lead_provider, name: "Lead Provider Example") }
      let!(:provider_two) { FactoryBot.create(:npq_lead_provider, name: "Another Lead Provider Example") }

      it "returns all providers in name order" do
        expect(described_class.name_order).to eq([provider_two, provider_one])
      end
    end
  end
end
