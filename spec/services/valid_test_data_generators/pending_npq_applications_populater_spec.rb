# frozen_string_literal: true

require "rails_helper"

RSpec.describe ValidTestDataGenerators::PendingNPQApplicationsPopulater do
  let(:npq_lead_provider) { create(:npq_lead_provider) }
  let(:cohort) { create(:cohort, :current) }
  let!(:school) { create(:school) }
  let!(:npq_course) { create(:npq_specialist_course) }

  before do
    allow(Rails).to receive(:env) { environment.inquiry }
  end

  subject { described_class.populate(name: npq_lead_provider.name, cohort:, number_of_participants: 22) }

  describe "#populate" do
    context "when running in other environment other than sandbox or development" do
      let(:environment) { "test" }

      it "returns nil" do
        expect(subject).to be_nil
        expect(NPQApplication.count).to eq(0)
      end
    end

    context "when running in development or sandbox environments" do
      let(:environment) { "sandbox" }

      it "creates participants" do
        subject

        expect(User.count).to eq(22)
        expect(NPQApplication.count).to eq(22)
        expect(NPQApplication.where(lead_provider_approval_status: "pending").count).to eq(22)
        expect(NPQApplication.all.map(&:cohort).uniq.first).to eq(cohort)
        expect(NPQApplication.all.map(&:npq_lead_provider).uniq.first).to eq(npq_lead_provider)
        expect(NPQApplication.all.map(&:school).uniq.first).to eq(school)
        expect(NPQApplication.all.map(&:npq_course).uniq.first).to eq(npq_course)
      end
    end
  end
end
