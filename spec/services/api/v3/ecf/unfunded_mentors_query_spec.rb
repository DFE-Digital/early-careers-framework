# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V3::ECF::UnfundedMentorsQuery do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let(:lead_provider) { cpd_lead_provider.lead_provider }
  let(:cohort) { Cohort.current || create(:cohort, :current) }
  let(:partnership) { create(:partnership, lead_provider:, cohort:) }
  let(:mentor_participant_profile) { create(:mentor_participant_profile) }
  let(:participant_profile) { create(:ect_participant_profile, mentor_profile_id: mentor_participant_profile.id) }
  let(:induction_programme) { create(:induction_programme, :fip, partnership:) }
  let!(:induction_record) { create(:induction_record, induction_programme:, participant_profile:, mentor_profile_id: mentor_participant_profile.id) }
  let(:unfunded_mentor_participant_profile) { create(:mentor_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, cohort:) }
  let(:another_induction_programme) { create(:induction_programme, :fip, school_cohort: unfunded_mentor_participant_profile.school_cohort) }
  let!(:unfunded_mentor_induction_record) { create(:induction_record, induction_programme: another_induction_programme, participant_profile: unfunded_mentor_participant_profile) }

  let(:params) { {} }

  subject { described_class.new(lead_provider:, params:) }

  describe "#unfunded_mentors" do
    it "returns all unfunded mentors" do
      expect(subject.unfunded_mentors.size).to eq(1)
      expect(subject.unfunded_mentors.first.user_id).to eq(unfunded_mentor_participant_profile.user_id)
    end

    context "with preferred identity" do
      let(:preferred_email) { Faker::Internet.email }
      let(:preferred_identity) { create(:participant_identity, :secondary, user: unfunded_mentor_participant_profile.user, email: preferred_email) }
      let!(:another_induction_record) { create(:induction_record, induction_programme: another_induction_programme, participant_profile: unfunded_mentor_participant_profile, preferred_identity:) }
      let(:user_id) { unfunded_mentor_participant_profile.participant_identity.user_id }

      it "returns the user id of the participant identity" do
        expect(subject.unfunded_mentors.first.user_id).to eq(user_id)
      end

      it "returns the preferred email" do
        expect(subject.unfunded_mentors.first.preferred_identity_email).to eq(preferred_email)
      end
    end

    describe "updated_since filter" do
      context "with correct value" do
        let(:another_participant_profile) { create(:mentor_participant_profile) }
        let!(:another_induction_record) { create(:induction_record, induction_programme: another_induction_programme, participant_profile: another_participant_profile) }

        let(:params) { { filter: { updated_since: 1.day.ago.iso8601 } } }

        before { another_participant_profile.user.update(updated_at: 4.days.ago.iso8601) }

        it "returns all induction_records for the specific updated_since filter" do
          expect(subject.unfunded_mentors.size).to eq(1)
          expect(subject.unfunded_mentors.first.user_id).to eq(unfunded_mentor_induction_record.user.id)
        end
      end
    end
  end

  describe "#unfunded_mentor" do
    describe "id filter" do
      context "with correct value" do
        let(:another_participant_profile) { create(:mentor_participant_profile) }
        let!(:another_induction_record) { create(:induction_record, induction_programme: another_induction_programme, participant_profile: another_participant_profile) }

        let(:params) { { id: another_participant_profile.participant_identity.user_id } }

        it "returns a specific induction record" do
          expect(subject.unfunded_mentor.user_id).to eql(another_participant_profile.user.id)
        end
      end

      context "with incorrect value" do
        let(:params) { { id: SecureRandom.uuid } }

        it "raises an error" do
          expect {
            subject.unfunded_mentor
          }.to raise_error(Api::Errors::RecordNotFoundError)
        end
      end

      context "when mentor is also an ECT" do
        let(:user) { unfunded_mentor_participant_profile.participant_identity.user }
        let(:mentor_participant_profile) { create(:ect_participant_profile, user:, teacher_profile: unfunded_mentor_participant_profile.teacher_profile) }

        # set ID on induction records to ensure test fails consistently, as they are chosen by asc order
        let!(:ect_induction_record) do
          create(:induction_record, induction_programme:, participant_profile:, id: "bb9fd4c7-bdce-4338-a42d-723876f514bc")
        end
        let!(:mentor_induction_record) do
          create(:induction_record, induction_programme:, participant_profile: mentor_participant_profile, id: "aa1fd4c7-bdce-4338-a42d-723876f514bc")
        end

        let(:params) { { id: user.id } }

        it "returns the ECT induction record only" do
          expect(subject.unfunded_mentor.user_id).to eql(user.id)
        end
      end
    end
  end
end
