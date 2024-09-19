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

      it "deletes the application which does not exist in NPQ" do
        expect { run }.to change { NPQApplication.count }.by(-1)
      end

      it "keeps the accepted application" do
        run

        expect { application.reload }.to raise_error(ActiveRecord::RecordNotFound)
        expect { similar_application.reload }.not_to raise_error
      end
    end

    context "when there is a rejected application" do
      let!(:application) { create(:npq_application, :accepted) }
      let!(:similar_application) do
        create(:npq_application, :rejected,
               npq_course: application.npq_course,
               npq_lead_provider: application.npq_lead_provider,
               user: application.user,
               cohort: application.cohort)
      end
      let(:npq_application_ids) { [application.id, similar_application.id] }

      it "deletes all applications which does not exist in NPQ" do
        expect { run }.to change { NPQApplication.count }.by(-1)
      end

      it "keeps the accepted application" do
        run

        expect { application.reload }.not_to raise_error
        expect { similar_application.reload }.to raise_error(ActiveRecord::RecordNotFound)
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

      it "deletes all applications which does not exist in NPQ" do
        expect { run }.to change { NPQApplication.count }.by(-2)
      end

      it "keeps the latest pending application" do
        run

        expect { application.reload }.to raise_error(ActiveRecord::RecordNotFound)
        expect { similar_application.reload }.to raise_error(ActiveRecord::RecordNotFound)
        expect { another_similar_application.reload }.not_to raise_error
      end
    end

    context "when the application is rejected" do
      let!(:application) { create(:npq_application, :rejected) }
      let!(:similar_application) do
        create(:npq_application, :rejected,
               npq_course: application.npq_course,
               npq_lead_provider: application.npq_lead_provider,
               user: application.user,
               cohort: application.cohort)
      end
      let(:npq_application_ids) { [application.id, similar_application.id] }

      it "deletes all applications which does not exist in NPQ" do
        expect { run }.to change { NPQApplication.count }.by(-1)
      end

      it "keeps the latest rejected application" do
        run

        expect { application.reload }.to raise_error(ActiveRecord::RecordNotFound)
        expect { similar_application.reload }.not_to raise_error
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
