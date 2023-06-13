# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::RecordsAnalysisController, :with_default_schedules, type: :request do
  let(:admin_profile) { NewSeeds::Scenarios::Users::AdminUser.new.build }

  before { sign_in admin_profile.user }

  describe "GET /admin/records-analysis" do
    it "renders the index template by default" do
      get "/admin/records-analysis"

      expect(response).to render_template "admin/records_analysis/index"
    end
  end

  describe "GET /admin/records-analysis/invalid-payments" do
    describe "when no records can be found" do
      it "renders the invalid_payments_analysis template for payments made against invalid NPQ applications" do
        get "/admin/records-analysis/invalid-payments"

        expect(response).to render_template "admin/records_analysis/invalid_payments"
      end
    end

    describe "when a record can be found" do
      let(:npq_lead_provider) { create(:seed_npq_lead_provider, :with_cpd_lead_provider) }
      let(:cpd_lead_provider) { npq_lead_provider.cpd_lead_provider }

      let!(:rejected_npq_application_with_payable_declaration) do
        npq_application = create(:npq_application, :accepted, :eligible_for_funding, npq_lead_provider:)
        participant_profile = npq_application.profile

        create(:npq_participant_declaration, :payable, participant_profile:, cpd_lead_provider:)
        npq_application.update_column(:lead_provider_approval_status, :rejected)
        npq_application
      end

      it "renders the invalid_payments_analysis template for payments made against invalid NPQ applications" do
        get "/admin/records-analysis/invalid-payments"

        expect(response).to render_template "admin/records_analysis/invalid_payments"
      end
    end
  end

  describe "GET /admin/records-analysis/something-unexpected" do
    it "redirects back to the dashboard" do
      get "/admin/records-analysis/something-unexpected"

      expect(response).to redirect_to admin_records_analysis_path
    end
  end

  describe "GET /admin/records-analysis/bad-timelines" do
    describe "when no records can be found" do
      it "renders the invalid_payments_analysis template for payments made against invalid NPQ applications" do
        get "/admin/records-analysis/bad-timelines"

        expect(response).to render_template "admin/records_analysis/bad_timelines"
      end
    end

    describe "when a record can be found" do
      let!(:ect_on_fip_with_bad_timeline) do
        builder = NewSeeds::Scenarios::Participants::TrainingRecordStates.new.ect_on_fip_eligible

        first_induction_record = builder.participant_profile.induction_records.first
        start_date = first_induction_record.start_date

        builder.with_induction_record(induction_programme: first_induction_record.induction_programme, start_date:, end_date: start_date - 2.days)
        builder.with_induction_record(induction_programme: first_induction_record.induction_programme, start_date:, end_date: start_date - 1.day)
      end

      it "renders the invalid_payments_analysis template for payments made against invalid NPQ applications" do
        get "/admin/records-analysis/bad-timelines"

        expect(response).to render_template "admin/records_analysis/bad_timelines"
      end
    end
  end
end
