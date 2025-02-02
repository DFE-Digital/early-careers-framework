# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V3::ECF::UnfundedMentorsQuery do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let(:lead_provider) { cpd_lead_provider.lead_provider }
  let(:cohort) { Cohort.current || create(:cohort, :current) }
  let(:partnership) { create(:partnership, lead_provider:, cohort:) }
  let(:induction_programme) { create(:induction_programme, :fip, partnership:) }
  let!(:mentor_profile) { create(:mentor, lead_provider: cpd_lead_provider.lead_provider) }
  let!(:induction_record) { create(:induction_record, induction_programme:, mentor_profile:) }
  let!(:unfunded_mentor_participant_profile) { create(:mentor, :eligible_for_funding) }
  let!(:unfunded_mentor_induction_record) { create(:induction_record, induction_programme:, mentor_profile: unfunded_mentor_participant_profile) }
  let(:unfunded_mentor_profile_user_id) { unfunded_mentor_participant_profile.user.id }

  let(:params) { {} }

  subject { described_class.new(lead_provider:, params:) }

  describe "#unfunded_mentors" do
    it "returns all unfunded mentors" do
      expect(subject.unfunded_mentors.size).to eq(1)
      expect(subject.unfunded_mentors.first.user_id).to eq(unfunded_mentor_participant_profile.user_id)
    end

    context "when the mentor has multiple induction records with different preferred_identity associations" do
      let(:latest_preferred_identity) { create(:participant_identity, :secondary, user: unfunded_mentor_participant_profile.user) }
      let(:other_induction_programme) { create(:induction_programme, :fip, partnership: other_partnership) }
      let(:other_partnership) { create(:partnership, lead_provider: other_lead_provider, cohort:) }
      let(:other_lead_provider) { create(:lead_provider) }
      let!(:latest_induction_record) { create(:induction_record, :future_start_date, induction_programme: other_induction_programme, participant_profile: unfunded_mentor_participant_profile, preferred_identity: latest_preferred_identity) }

      it "returns the preferred email from the latest induction record" do
        expect(unfunded_mentor_participant_profile.induction_records.pluck(&:participant_email).uniq.count).to eq(2)
        expect(subject.unfunded_mentors.first.preferred_identity_email).to eq(latest_preferred_identity.email)
      end
    end

    describe "updated_since filter" do
      context "with correct value" do
        let!(:another_unfunded_mentor_profile) { create(:mentor, :eligible_for_funding) }
        let!(:another_unfunded_mentor_induction_record) { create(:induction_record, induction_programme:, mentor_profile: another_unfunded_mentor_profile) }

        let(:params) { { filter: { updated_since: 1.day.ago.iso8601 } } }

        before { another_unfunded_mentor_profile.user.update(updated_at: 4.days.ago.iso8601) }

        it "returns all induction_records for the specific updated_since filter" do
          expect(subject.unfunded_mentors.size).to eq(1)
          expect(subject.unfunded_mentors.first.user_id).to eq(unfunded_mentor_profile_user_id)
        end
      end
    end

    describe "sorting" do
      let(:user) do
        travel_to(10.days.ago) do
          create(:user, email: "mary.lewis@example.com")
        end
      end
      let!(:another_unfunded_mentor_profile) { create(:mentor, :eligible_for_funding, user:) }
      let!(:another_unfunded_mentor_induction_record) { create(:induction_record, induction_programme:, mentor_profile: another_unfunded_mentor_profile) }

      context "when no sort parameter is specified" do
        it "returns all records ordered by user created_at ascending by default" do
          expect(subject.unfunded_mentors.map(&:user_id)).to eq([another_unfunded_mentor_profile.user.id, unfunded_mentor_profile_user_id])
        end
      end

      context "when created_at sort parameter is specified" do
        let(:params) { { sort: "-created_at" } }

        it "returns records in the correct order" do
          expect(subject.unfunded_mentors.map(&:user_id)).to eq([unfunded_mentor_profile_user_id, another_unfunded_mentor_profile.user.id])
        end
      end

      context "when updated_at sort parameter is specified" do
        let(:params) { { sort: "updated_at" } }

        it "returns records in the correct order" do
          expect(subject.unfunded_mentors.map(&:user_id)).to eq([unfunded_mentor_profile_user_id, another_unfunded_mentor_profile.user.id])
        end
      end
    end
  end

  describe "#unfunded_mentor" do
    describe "id filter" do
      context "with correct value" do
        let!(:another_unfunded_mentor_profile) { create(:mentor, :eligible_for_funding) }
        let!(:another_unfunded_mentor_induction_record) { create(:induction_record, induction_programme:, mentor_profile: another_unfunded_mentor_profile) }

        let(:params) { { id: another_unfunded_mentor_profile.participant_identity.user_id } }

        it "returns a specific induction record" do
          expect(subject.unfunded_mentor.user_id).to eql(another_unfunded_mentor_profile.user.id)
        end
      end

      context "with incorrect value" do
        let(:params) { { id: SecureRandom.uuid } }

        it "raises an error" do
          expect {
            subject.unfunded_mentor
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end
end
