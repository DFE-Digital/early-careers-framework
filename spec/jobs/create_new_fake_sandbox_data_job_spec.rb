# frozen_string_literal: true

require "rails_helper"

RSpec.describe CreateNewFakeSandboxDataJob, type: :job do
  describe "#perform" do
    subject { described_class.new }

    let!(:cpd_lead_provider) { create(:cpd_lead_provider, name: "Education Development Trust") }
    let!(:ecf_lead_provider) { create(:lead_provider, cpd_lead_provider:, name: "Education Development Trust") }
    let!(:cohort) { Cohort.current }
    let!(:school) { create(:school) }
    let!(:school_cohort) { create(:school_cohort, school:, cohort:) }

    before do
      create(:partnership, lead_provider: ecf_lead_provider, cohort:, school:)
    end

    it "should create 10 new ECTs" do
      subject.perform

      expect(ecf_lead_provider.reload.ecf_participants.count).to eq(10)
    end
  end
end
