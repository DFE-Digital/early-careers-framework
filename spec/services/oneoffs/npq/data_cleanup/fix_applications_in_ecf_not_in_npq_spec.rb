# frozen_string_literal: true

describe Oneoffs::NPQ::DataCleanup::FixApplicationsInECFNotInNPQ do
  let(:npq_application_ids) { [application.id] }
  let(:instance) { described_class.new(npq_application_ids:) }

  describe "#run!" do
    let(:dry_run) { false }

    subject(:run) { instance.run!(dry_run:) }

    context "when there is an accepted application" do
      let!(:application) { create(:npq_application) }
      let!(:similar_application) do
        create(:npq_application, :accepted,
               npq_course: application.npq_course,
               npq_lead_provider: application.npq_lead_provider,
               user: application.user,
               cohort: application.cohort)
      end
      let(:npq_application_ids) { [application.id, similar_application.id] }

      it "deletes it" do
        expect { run }.to change { NPQApplication.count }.by(-1)
      end
    end

    context "when there is a rejected application" do
      let!(:application) { create(:npq_application, :rejected) }
      let!(:similar_application) do
        create(:npq_application, :rejected,
               npq_course: application.npq_course,
               npq_lead_provider: application.npq_lead_provider,
               user: application.user,
               cohort: application.cohort)
      end
      let(:npq_application_ids) { [application.id, similar_application.id] }

      it "deletes it" do
        expect { run }.to change { NPQApplication.count }.by(-1)
      end
    end

    context "when the application is pending" do
      let!(:application) { create(:npq_application, :pending) }
      let!(:similar_application) do
        create(:npq_application, :pending,
               npq_course: application.npq_course,
               npq_lead_provider: application.npq_lead_provider,
               user: application.user,
               cohort: application.cohort)
      end
      let!(:another_similar_application) do
        create(:npq_application, :pending,
               npq_course: application.npq_course,
               npq_lead_provider: application.npq_lead_provider,
               user: application.user,
               cohort: application.cohort)
      end
      let(:npq_application_ids) { [application.id, similar_application.id, another_similar_application.id] }

      it "deletes it" do
        expect { run }.to change { NPQApplication.count }.by(-1)
      end
    end

    context "when the application is pending" do
      let!(:application) { create(:npq_application, :rejected) }
      let!(:similar_application) do
        create(:npq_application, :rejected,
               npq_course: application.npq_course,
               npq_lead_provider: application.npq_lead_provider,
               user: application.user,
               cohort: application.cohort)
      end
      let(:npq_application_ids) { [application.id, similar_application.id] }

      it "deletes it" do
        expect { run }.to change { NPQApplication.count }.by(-1)
      end
    end

    context "when dry_run is true" do
      let(:dry_run) { true }

      let!(:application) { create(:npq_application, :accepted) }

      it "does not delete it" do
        expect { run }.not_to change { NPQApplication.count }
      end
    end
  end
end
