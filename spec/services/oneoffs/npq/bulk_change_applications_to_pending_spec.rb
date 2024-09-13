# frozen_string_literal: true

describe Oneoffs::NPQ::BulkChangeApplicationsToPending do
  let(:npq_application_ids) { [application.id] }
  let(:instance) { described_class.new(npq_application_ids:) }

  describe "#run!" do
    let(:dry_run) { false }

    subject(:run) { instance.run!(dry_run:) }

    shared_context "changes to pending" do |initial_state|
      it { expect { run }.to change { application.reload.lead_provider_approval_status }.from(initial_state).to("pending") }
      it { expect(run[application.id]).to eq("Changed to pending") }
    end

    shared_context "does not change to pending" do |result|
      it { expect { run }.not_to change { application.reload.lead_provider_approval_status } }
      it { expect(run[application.id]).to match(result) }
    end

    context "when there is an accepted application" do
      let(:application) { create(:npq_application, :accepted) }

      it_behaves_like "changes to pending", "accepted"
    end

    context "when there is an rejected application" do
      let(:application) { create(:npq_application, :rejected) }

      it_behaves_like "changes to pending", "rejected"
    end

    %i[submitted voided ineligible].each do |state|
      context "when the application has #{state} declarations" do
        let(:participant_declaration) { create(:npq_participant_declaration, state) }

        context "when the application is accepted" do
          let(:application) { participant_declaration.participant_profile.npq_application }

          it_behaves_like "changes to pending", "accepted"
        end

        context "when the application is rejected" do
          let(:application) do
            participant_declaration.participant_profile.npq_application.tap do |application|
              application.update!(lead_provider_approval_status: "rejected")
            end
          end

          it_behaves_like "changes to pending", "rejected"
        end
      end
    end

    context "when the application is already pending" do
      let(:application) { create(:npq_application, :pending) }

      it_behaves_like "does not change to pending", "Already pending"
    end

    context "when the application doesn't exist" do
      let(:application_id) { SecureRandom.uuid }
      let(:npq_application_ids) { [application_id] }

      it { expect(run[application_id]).to eq("Not found") }
    end

    ParticipantDeclaration.states.keys.excluding("submitted", "voided", "ineligible").each do |state|
      context "when the application has #{state} declarations" do
        let(:participant_declaration) { create(:npq_participant_declaration, state) }
        let(:application) { participant_declaration.participant_profile.npq_application }

        it_behaves_like "does not change to pending", /declarations_exist/
      end
    end

    context "when dry_run is true" do
      let(:dry_run) { true }

      let(:application) { create(:npq_application, :accepted) }

      it { expect { run }.not_to change { application.reload.lead_provider_approval_status } }
      it { expect(run[application.id]).to eq("Changed to pending") }
    end
  end
end
