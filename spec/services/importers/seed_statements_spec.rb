# frozen_string_literal: true

RSpec.describe Importers::SeedStatements do
  let!(:cpd_lead_provider) do
    create(:cpd_lead_provider, :with_lead_provider, :with_npq_lead_provider)
  end

  describe "#call" do
    it "creates ECF statements idempotently" do
      expect {
        subject.call
        subject.call
      }.to change(Finance::Statement::ECF, :count).by(3)
    end

    it "creates NPQ statements idempotently" do
      expect {
        subject.call
        subject.call
      }.to change(Finance::Statement::NPQ, :count).by(2)
    end
  end
end
