# frozen_string_literal: true

require "rails_helper"

RSpec.describe "CreateNewFakeSandboxDataJob" do
  describe "#perform" do
    let!(:npq_course) { create(:npq_course, identifier: "npq-senior-leadership") }
    let!(:cpd_lead_provider) { create(:cpd_lead_provider, name: "Education Development Trust") }
    let!(:ecf_lead_provider) { create(:lead_provider, cpd_lead_provider:, name: "Education Development Trust") }
    let!(:npq_lead_provider) { create(:npq_lead_provider, cpd_lead_provider:, name: "Education Development Trust") }
    let!(:cohort) { Cohort.current }
    let!(:school) { create(:school) }
    let!(:school_cohort) { create(:school_cohort, school:, cohort:) }

    before do
      create(:partnership, lead_provider: ecf_lead_provider, cohort:, school:)
    end

    it "should create 10 new ECTs" do
      CreateNewFakeSandboxDataJob.new.perform

      expect(ecf_lead_provider.reload.ecf_participants.count).to eq(10)
    end

    it "should create 10 new NPQ applications" do
      CreateNewFakeSandboxDataJob.new.perform

      expect(npq_lead_provider.reload.npq_applications.count).to eq(10)
      expect(npq_lead_provider.reload.npq_participants.count).to eq(0)
    end

    it "should associate the NPQ applications to the active registration cohort" do
      CreateNewFakeSandboxDataJob.new.perform

      expect(npq_lead_provider.reload.npq_applications.last.cohort.start_year).to eq(Cohort.active_registration_cohort.start_year)
    end
  end
end
