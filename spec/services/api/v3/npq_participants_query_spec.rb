# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V3::NPQParticipantsQuery do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_npq_lead_provider) }
  let(:npq_lead_provider) { cpd_lead_provider.npq_lead_provider }
  let(:npq_course) { create(:npq_course, identifier: "npq-senior-leadership") }
  let(:user) { create(:user, full_name: "John Doe") }
  let(:teacher_profile) { create(:teacher_profile, user:, trn: "1234567") }
  let!(:participant_profile) { create(:npq_participant_profile, npq_lead_provider:, npq_course:, teacher_profile:, user:) }

  let(:params) { {} }
  let(:instance) { described_class.new(npq_lead_provider:, params:) }

  describe "#participants" do
    subject(:participants) { instance.participants }

    it { is_expected.to contain_exactly(user) }

    describe "training_status filter" do
      let(:training_status) { :deferred }
      let(:params) { { filter: { training_status: } } }

      context "when there are no matches" do
        it { is_expected.to be_empty }
      end

      context "when there are matches" do
        let!(:another_participant_profile) { create(:npq_participant_profile, npq_lead_provider:, npq_course:, training_status: :withdrawn) }
        let(:training_status) { participant_profile.training_status }

        it { is_expected.to contain_exactly(user) }
      end

      context "with an invalid value" do
        let(:training_status) { :invalid }
        let(:expected_message) { %(The filter '#/training_status' must be ["active", "deferred", "withdrawn"]) }

        it { expect { participants }.to raise_error(Api::Errors::InvalidTrainingStatusError, expected_message) }
      end
    end

    describe "from_participant_id filter" do
      let(:params) { { filter: { from_participant_id: } } }

      context "ID does not exist" do
        let(:from_participant_id) { "doesnotexist" }
        it { is_expected.to be_empty }
      end

      context "ID with a match" do
        let!(:another_user) { create(:npq_participant_profile, npq_lead_provider:, npq_course:, training_status: :withdrawn).user }
        let!(:participant_id_change1) { create(:participant_id_change, to_participant: user, user:) }
        let!(:participant_id_change2) { create(:participant_id_change, to_participant: another_user, user: another_user) }
        let(:from_participant_id) { participant_id_change1.from_participant_id }

        it { is_expected.to contain_exactly(user) }
      end
    end

    describe "updated_since filter" do
      let!(:another_participant_profile) { create(:npq_participant_profile, npq_lead_provider:, npq_course:) }
      let(:params) { { filter: { updated_since: 1.day.ago.iso8601 } } }

      before { another_participant_profile.user.update(updated_at: 4.days.ago.iso8601) }

      context "with correct value" do
        it "returns all records for the specific updated_since filter" do
          is_expected.to contain_exactly(user)
        end
      end

      context "with incorrect value" do
        let(:params) { { filter: { updated_since: SecureRandom.uuid } } }

        it { expect { participants }.to raise_error(Api::Errors::InvalidDatetimeError) }
      end
    end

    describe "sorting" do
      let!(:another_participant_profile) do
        travel_to(10.days.ago) do
          create(:npq_participant_profile, npq_lead_provider:, npq_course:)
        end
      end

      context "when no sort parameter is specified" do
        it "returns all records ordered by participant profile created_at ascending by default" do
          expect(participants.map(&:id)).to eq(
            [another_participant_profile, participant_profile].map(&:user_id),
          )
        end
      end

      context "when created_at sort parameter is specified" do
        let(:params) { { sort: "-created_at" } }

        it "returns records in the correct order" do
          expect(participants.map(&:id)).to eq(
            [participant_profile, another_participant_profile].map(&:user_id),
          )
        end
      end

      context "when updated_at sort parameter is specified" do
        let(:params) { { sort: "updated_at" } }

        it "returns records in the correct order" do
          expect(participants.map(&:id)).to eq(
            [another_participant_profile, participant_profile].map(&:user_id),
          )
        end
      end
    end
  end

  describe "#participant" do
    subject(:participant) { instance.participant }

    context "with correct params" do
      let(:params) { { id: participant_profile.user_id } }

      it { is_expected.to eq(user) }
    end

    context "with incorrect params" do
      let(:params) { { id: SecureRandom.uuid } }

      it { expect { participant }.to raise_error(ActiveRecord::RecordNotFound) }
    end

    context "with no params" do
      it { expect { participant }.to raise_error(ActiveRecord::RecordNotFound) }
    end
  end
end
