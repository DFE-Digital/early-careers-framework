# frozen_string_literal: true

require "rails_helper"

RSpec.describe ValidTestDataGenerators::NPQLeadProviderPopulater do
  let(:npq_lead_provider) { create(:npq_lead_provider) }
  let(:cohort) { create(:cohort, :current) }
  let!(:school) { create(:school) }
  let!(:npq_course) { create(:npq_specialist_course) }

  before do
    allow(Rails).to receive(:env) { environment.inquiry }
    allow(Faker::Boolean).to receive(:boolean).and_return(false)

    create(
      :npq_contract,
      npq_lead_provider:,
      cohort:,
      course_identifier: npq_course.identifier,
    )

    create(
      :npq_statement,
      :next_output_fee,
      cpd_lead_provider: npq_lead_provider.cpd_lead_provider,
      cohort:,
    )
  end

  subject { described_class.populate(name: npq_lead_provider.name, cohort:, total_schools: 1, participants_per_school: 5) }

  describe "#populate" do
    context "when running in other environment other than sandbox or development" do
      let(:environment) { "test" }

      it "returns nil" do
        expect(subject).to be_nil
      end
    end

    context "when running in development or sandbox environments" do
      let(:environment) { "sandbox" }

      it "creates users # given in the params" do
        expect {
          subject
        }.to change(User, :count).by(5)
      end

      it "creates applications" do
        expect {
          subject
        }.to(change(NPQApplication, :count))
      end

      it "creates applications for the given cohort" do
        subject

        expect(NPQApplication.all.map(&:cohort).uniq.first).to eq(cohort)
      end

      it "creates applications for the given lead provider" do
        subject

        expect(NPQApplication.all.map(&:npq_lead_provider).uniq.first).to eq(npq_lead_provider)
      end

      it "creates accepted applications" do
        expect {
          subject
        }.to(change { NPQApplication.accepted.count })
      end

      it "creates eligible for funding applications" do
        expect {
          subject
        }.to(change { NPQApplication.where(eligible_for_funding: true).count })
      end

      it "creates declarations" do
        expect {
          subject
        }.to(change(ParticipantDeclaration, :count))
      end
    end
  end
end
