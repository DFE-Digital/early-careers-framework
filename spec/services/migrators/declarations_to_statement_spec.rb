# frozen_string_literal: true

require "rails_helper"

RSpec.describe Migrators::DeclarationsToStatement do
  let!(:cpd_lead_provider) { create(:cpd_lead_provider) }

  let!(:ecf_statement) { Finance::Statement::ECF.create!(name: "November 2021", cpd_lead_provider: cpd_lead_provider) }
  let!(:ecf_declaration) { create(:ect_participant_declaration, cpd_lead_provider: cpd_lead_provider, state: "paid") }

  let!(:npq_statement) { Finance::Statement::NPQ.create!(name: "December 2021", cpd_lead_provider: cpd_lead_provider) }
  let!(:npq_declaration) { create(:npq_participant_declaration, cpd_lead_provider: cpd_lead_provider, state: "payable") }

  describe "#call" do
    it "assigns ECF paid declarations" do
      expect { subject.call }.to change { ecf_declaration.reload.statement }.from(nil).to(ecf_statement)
    end

    it "assigns NPQ payable declarations" do
      expect { subject.call }.to change { npq_declaration.reload.statement }.from(nil).to(npq_statement)
    end
  end
end
