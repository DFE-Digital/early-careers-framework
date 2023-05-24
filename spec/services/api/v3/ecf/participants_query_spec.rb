# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V3::ECF::ParticipantsQuery do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let(:lead_provider) { cpd_lead_provider.lead_provider }
  let(:cohort) { Cohort.current || create(:cohort, :current) }
  let(:partnership) { create(:partnership, lead_provider:, cohort:) }
  let(:participant_profile) { create(:ect_participant_profile) }
  let(:induction_programme) { create(:induction_programme, :fip, partnership:) }
  let(:induction_record) { create(:induction_record, induction_programme:, participant_profile:) }
  let!(:user) { induction_record.user }

  let(:params) { {} }

  subject { described_class.new(lead_provider:, params:) }

  describe "#participants" do
    it "returns all induction records" do
      expect(subject.participants).to match_array([user])
    end

    context "with preferred identity" do
      let(:preferred_email) { Faker::Internet.email }
      let(:preferred_identity) { create(:participant_identity, :secondary, user: participant_profile.user, email: preferred_email) }
      let!(:another_induction_record) { create(:induction_record, induction_programme:, participant_profile:, preferred_identity:) }
      let(:user_id) { participant_profile.participant_identity.user_id }

      it "returns the user id of the participant identity" do
        expect(subject.participants.first.id).to eq(user_id)
      end

      it "returns the preferred email" do
        expect(subject.participants.first.participant_profiles.first.induction_records.first.preferred_identity.email).to eq(preferred_email)
      end
    end

    context "with mentor profile" do
      let(:mentor_participant_profile) { create(:mentor_participant_profile) }
      let(:participant_profile) { create(:ect_participant_profile, mentor_profile_id: mentor_participant_profile.id) }
      let(:user_id) { participant_profile.participant_identity.user_id }
      let(:mentor_user_id) { mentor_participant_profile.participant_identity.user_id }
      let!(:induction_record) { create(:induction_record, induction_programme:, participant_profile:, mentor_profile_id: mentor_participant_profile.id) }

      it "returns the mentor user id" do
        expect(subject.participants.first.participant_profiles.first.mentor.id).to eq(mentor_user_id)
      end

      it "returns the user id" do
        expect(subject.participants.first.id).to eq(user_id)
      end
    end

    describe "cohort filter" do
      context "with correct value" do
        let(:params) { { filter: { cohort: cohort.display_name } } }

        it "returns all user records for the specific cohort" do
          expect(subject.participants).to match_array([user])
        end
      end

      context "with multiple values" do
        let(:another_cohort) { create(:cohort, start_year: "2050") }
        let!(:another_partnership) { create(:partnership, cohort: another_cohort, lead_provider:) }
        let(:another_participant_profile) { create(:ect_participant_profile) }
        let(:another_induction_programme) { create(:induction_programme, :fip, partnership: another_partnership) }
        let(:another_induction_record) { create(:induction_record, induction_programme: another_induction_programme, participant_profile: another_participant_profile) }
        let!(:another_user) { another_induction_record.user }

        let(:params) { { filter: { cohort: "#{cohort.start_year},#{another_cohort.start_year}" } } }

        it "returns all user records for the specific cohort" do
          expect(subject.participants).to match_array([user, another_user])
        end
      end

      context "with incorrect value" do
        let(:params) { { filter: { cohort: "2017" } } }

        it "returns no user records" do
          expect(subject.participants).to be_empty
        end
      end
    end

    describe "updated_since filter" do
      context "with correct value" do
        let(:another_participant_profile) { create(:ect_participant_profile) }
        let(:another_induction_programme) { create(:induction_programme, :fip, partnership:) }
        let!(:another_induction_record) { create(:induction_record, induction_programme: another_induction_programme, participant_profile: another_participant_profile) }

        let(:params) { { filter: { updated_since: 1.day.ago.iso8601 } } }

        before { another_participant_profile.user.update(updated_at: 4.days.ago.iso8601) }

        it "returns all user records for the specific updated_since filter" do
          expect(subject.participants).to match_array([user])
        end
      end
    end

    context "sorting" do
      let(:another_cohort) { create(:cohort, start_year: "2050") }
      let!(:another_partnership) { create(:partnership, cohort: another_cohort, lead_provider:) }
      let(:another_participant_profile) do
        travel_to(10.days.ago) do
          create(:ect_participant_profile)
        end
      end

      let(:another_induction_programme) { create(:induction_programme, :fip, partnership: another_partnership) }
      let(:another_induction_record) { create(:induction_record, induction_programme: another_induction_programme, participant_profile: another_participant_profile) }
      let!(:another_user) { another_induction_record.user }

      it "returns all user records ordered by participant profile created_at" do
        expect(subject.participants).to eq([another_user, user])
      end
    end
  end

  describe "#participant" do
    describe "id filter" do
      context "with correct value" do
        let(:another_participant_profile) { create(:ect_participant_profile) }
        let(:another_induction_programme) { create(:induction_programme, :fip, partnership:) }
        let(:another_induction_record) { create(:induction_record, induction_programme: another_induction_programme, participant_profile: another_participant_profile) }
        let!(:another_user) { another_induction_record.user }

        let(:params) { { id: another_user.id } }

        it "returns a specific user record" do
          expect(subject.participant).to eql(another_user)
        end
      end

      context "with incorrect value" do
        let(:params) { { id: SecureRandom.uuid } }

        it "raises an error" do
          expect {
            subject.participant
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "when participant is a mentor" do
        let(:participant_profile) { create(:mentor_participant_profile) }
        let(:params) { { id: participant_profile.participant_identity.user_id } }

        it "returns the Mentor user record only" do
          expect(subject.participant).to eql(participant_profile.user)
        end
      end

      context "when ECT is also a mentor" do
        let!(:mentor_participant_profile) { create(:mentor_participant_profile, user:, teacher_profile: participant_profile.teacher_profile) }

        let(:params) { { id: user.id } }

        it "returns the one user record only" do
          expect(subject.participant).to eql(user)
        end
      end
    end
  end
end
