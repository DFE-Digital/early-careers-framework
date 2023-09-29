# frozen_string_literal: true

RSpec.describe Admin::Participants::ChangeRelationship::ChangeRelationshipWizard, type: :model do
  let(:current_step) { :reason_for_change }
  let(:data_store) { instance_double(FormData::ChangeParticipantRelationshipStore) }
  let(:admin_user) { create(:seed_admin_profile, :with_user) }
  let(:request) { {} }
  let!(:participant_profile) { create(:seed_ect_participant_profile, :valid) }

  let(:submitted_params) { {} }

  subject(:wizard) { described_class.new(current_step:, default_step_name: :reason_for_change, data_store:, current_user: admin_user, participant_profile:, request:, submitted_params:) }

  before do
    allow(data_store).to receive(:set)
    allow(data_store).to receive(:participant_profile).and_return(participant_profile)
  end

  describe "#programme_can_be_changed?" do
    let(:circumstances_change) { false }
    let(:has_declarations) { false }

    before do
      allow(data_store).to receive(:reason_for_change_circumstances?).and_return(circumstances_change)
      allow(wizard).to receive(:participant_has_declarations_with_the_current_provider?).and_return(has_declarations)
    end

    context "when the reason for change is mistake" do
      it "returns true" do
        expect(wizard).to be_programme_can_be_changed
      end

      context "when the participant has declarations with their current provider" do
        let(:has_declarations) { true }

        it "returns false" do
          expect(wizard).not_to be_programme_can_be_changed
        end
      end
    end

    context "when the reason for change is circumstances" do
      let(:circumstances_change) { true }

      it "returns true" do
        expect(wizard).to be_programme_can_be_changed
      end
    end
  end
end
