# frozen_string_literal: true

require "rails_helper"

RSpec.describe Finance::PaymentBreakdownsController do
  let(:user) { create(:user, :finance) }

  let(:cohort_2021) { Cohort.current || create(:cohort, :current) }
  let(:cohort_2022) { Cohort.next || create(:cohort, :next) }

  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider, :with_npq_lead_provider) }
  let(:lead_provider) { cpd_lead_provider.lead_provider }
  let(:npq_lead_provider) { cpd_lead_provider.npq_lead_provider }

  before do
    sign_in user
  end

  describe "POST #choose_ecf_statement" do
    let!(:statement_2021) { create(:ecf_statement, cpd_lead_provider:, name: "November 2022", cohort: cohort_2021) }
    let!(:statement_2022) { create(:ecf_statement, cpd_lead_provider:, name: "November 2022", cohort: cohort_2022) }

    it "redirects to correctly to 2021 statement" do
      post "/finance/payment-breakdowns/choose-ecf-statement", params: {
        lead_provider: lead_provider.id,
        cohort_year: cohort_2021.start_year,
        statement: statement_2021.name.downcase.gsub(" ", "-"),
      }

      expect(response).to redirect_to("/finance/ecf/payment_breakdowns/#{lead_provider.id}/statements/#{statement_2021.id}")
    end

    it "redirects to correctly to 2022 statement" do
      post "/finance/payment-breakdowns/choose-ecf-statement", params: {
        lead_provider: lead_provider.id,
        cohort_year: cohort_2022.start_year,
        statement: statement_2022.name.downcase.gsub(" ", "-"),
      }

      expect(response).to redirect_to("/finance/ecf/payment_breakdowns/#{lead_provider.id}/statements/#{statement_2022.id}")
    end
  end

  describe "POST #choose_npq_statement" do
    let!(:statement_2021) { create(:npq_statement, cpd_lead_provider:, name: "November 2022", cohort: cohort_2021) }
    let!(:statement_2022) { create(:npq_statement, cpd_lead_provider:, name: "November 2022", cohort: cohort_2022) }

    it "redirects to correctly to 2021 statement" do
      post "/finance/payment-breakdowns/choose-npq-statement", params: {
        npq_lead_provider: npq_lead_provider.id,
        cohort_year: cohort_2021.start_year,
        statement: statement_2021.name.downcase.gsub(" ", "-"),
      }

      expect(response).to redirect_to("/finance/npq/payment-overviews/#{npq_lead_provider.id}/statements/#{statement_2021.id}")
    end

    it "redirects to correctly to 2022 statement" do
      post "/finance/payment-breakdowns/choose-npq-statement", params: {
        npq_lead_provider: npq_lead_provider.id,
        cohort_year: cohort_2022.start_year,
        statement: statement_2022.name.downcase.gsub(" ", "-"),
      }

      expect(response).to redirect_to("/finance/npq/payment-overviews/#{npq_lead_provider.id}/statements/#{statement_2022.id}")
    end
  end
end
