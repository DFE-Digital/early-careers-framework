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

  subject { described_class.new(npq_lead_provider:, params:) }

  describe "#participants" do
    it "returns all participants" do
      expect(subject.participants).to match_array([user])
    end

    describe "updated_since filter" do
      let!(:another_participant_profile) { create(:npq_participant_profile, npq_lead_provider:, npq_course:) }
      let(:params) { { filter: { updated_since: 1.day.ago.iso8601 } } }

      before { another_participant_profile.user.update(updated_at: 4.days.ago.iso8601) }

      context "with correct value" do
        it "returns all records for the specific updated_since filter" do
          expect(subject.participants).to match_array([user])
        end
      end

      context "with incorrect value" do
        let(:params) { { filter: { updated_since: SecureRandom.uuid } } }

        it "raises an error" do
          expect {
            subject.participants
          }.to raise_error(Api::Errors::InvalidDatetimeError)
        end
      end
    end

    context "sorting" do
      let!(:another_participant_profile) do
        travel_to(10.days.ago) do
          create(:npq_participant_profile, npq_lead_provider:, npq_course:)
        end
      end

      it "returns all records ordered by participant profile created_at" do
        expect(subject.participants.map(&:id)).to eq([another_participant_profile.user_id, participant_profile.user_id])
      end
    end
  end

  describe "#participant" do
    context "with correct params" do
      let(:params) { { id: participant_profile.user_id } }

      it "returns a specific participant" do
        expect(subject.participant).to eq(user)
      end
    end

    context "with incorrect params" do
      let(:params) { { id: SecureRandom.uuid } }

      it "returns no participant" do
        expect { subject.participant }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "with no params" do
      it "returns no participant" do
        expect { subject.participant }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
