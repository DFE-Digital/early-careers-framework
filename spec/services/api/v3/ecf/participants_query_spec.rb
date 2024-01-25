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

  describe "#participants_for_pagination" do
    let(:another_cohort) { create(:cohort, start_year: "2050") }
    let(:another_schedule) { create(:schedule, name: "ECF September 2050", cohort: another_cohort) }
    let!(:another_partnership) { create(:partnership, cohort: another_cohort, lead_provider:) }
    let(:another_participant_profile) { create(:ect_participant_profile) }
    let(:another_induction_programme) { create(:induction_programme, :fip, partnership: another_partnership) }
    let(:another_induction_record) { create(:induction_record, induction_programme: another_induction_programme, participant_profile: another_participant_profile, schedule: another_schedule) }
    let!(:another_user) { another_induction_record.user }

    it "returns all users" do
      expect(subject.participants_for_pagination).to match_array([user, another_user])
    end

    context "with multiple providers" do
      let(:another_lead_provider) { create(:cpd_lead_provider, :with_lead_provider).lead_provider }
      let!(:another_partnership) { create(:partnership, cohort: another_cohort, lead_provider: another_lead_provider) }

      it "returns all users that belong to a provider" do
        expect(subject.participants_for_pagination).to match_array([user])
      end
    end

    context "when filtering by cohort" do
      let(:params) { { filter: { cohort: cohort.start_year.to_s } } }

      it "only returns users with induction records in the specified cohort" do
        expect(subject.participants_for_pagination).to match_array([user])
      end

      context "when the user has induction records against multiple cohorts" do
        let(:new_cohort) { Cohort.next }

        before do
          create(:school_cohort,
                 default_induction_programme: induction_programme,
                 school: induction_record.school,
                 cohort: new_cohort)
          create(:partnership,
                 school: induction_record.school,
                 lead_provider:,
                 cohort: new_cohort,
                 relationship: false)
          new_schedule = create(:ecf_schedule, name: "new-schedule", cohort: new_cohort)

          ChangeSchedule.new({
            cpd_lead_provider:,
            participant_id: participant_profile.participant_identity.external_identifier,
            course_identifier: "ecf-induction",
            schedule_identifier: new_schedule.schedule_identifier,
            cohort: new_cohort.start_year,
          }).call
        end

        context "when filtering by a historical cohort" do
          it { expect(subject.participants_for_pagination).to be_empty }
        end

        context "when filtering by their latest cohort" do
          let(:params) { { filter: { cohort: new_cohort.start_year.to_s } } }

          it { expect(subject.participants_for_pagination).to match_array([user]) }
        end
      end
    end

    describe "with training_status filter" do
      let(:training_status) { :deferred }
      let(:params) { { filter: { training_status: } } }

      context "when there are no matches" do
        it { expect(subject.participants_for_pagination).to be_empty }
      end

      context "when there are matches" do
        let(:training_status) { :active }

        it { expect(subject.participants_for_pagination).to contain_exactly(user, another_user) }
      end

      context "when the user has multiple induction records and the latest matches" do
        before { create(:induction_record, participant_profile:, induction_programme:, training_status: :withdrawn) }
        let(:training_status) { :withdrawn }

        it { expect(subject.participants_for_pagination).to contain_exactly(user) }
      end

      context "when the user has multiple induction records and the latest does not match" do
        before do
          participant_profile.induction_records.latest.update!(training_status: :deferred)
          create(:induction_record, participant_profile:, induction_programme:, training_status: :withdrawn)
        end

        it { expect(subject.participants_for_pagination).to be_empty }
      end

      context "with an invalid value" do
        let(:training_status) { :invalid }
        let(:expected_message) { %(The filter '#/training_status' must be ["active", "deferred", "withdrawn"]) }

        it { expect { subject.participants_for_pagination }.to raise_error(Api::Errors::InvalidTrainingStatusError, expected_message) }
      end
    end

    context "with updated_since filter" do
      let(:params) { { filter: { updated_since: 1.day.ago.iso8601 } } }
      let(:another_induction_record) do
        travel_to(10.days.ago) do
          create(:induction_record, induction_programme: another_induction_programme, participant_profile: another_participant_profile, schedule: another_schedule)
        end
      end

      it "returns all user records for the specific updated_since filter" do
        expect(subject.participants_for_pagination).to match_array([user])
      end
    end

    describe "with from_participant_id filter" do
      let(:params) { { filter: { from_participant_id: } } }

      context "ID does not exist" do
        let(:from_participant_id) { "doesnotexist" }
        it { expect(subject.participants_for_pagination).to be_empty }
      end

      context "ID with a match" do
        let!(:participant_id_change1) { create(:participant_id_change, to_participant: user, user:) }
        let!(:participant_id_change2) { create(:participant_id_change, to_participant: another_user, user: another_user) }
        let(:from_participant_id) { participant_id_change1.from_participant_id }

        it { expect(subject.participants_for_pagination).to contain_exactly(user) }
      end
    end

    context "with ect becoming mentor" do
      let(:mentor_participant_profile) { create(:mentor_participant_profile, participant_identity: user.participant_identities.first, teacher_profile: participant_profile.teacher_profile) }
      let(:mentor_induction_programme) { create(:induction_programme, :fip, partnership:) }
      let!(:mentor_induction_record) { create(:induction_record, induction_programme: mentor_induction_programme, participant_profile: mentor_participant_profile, preferred_identity: user.participant_identities.first) }

      it "returns all users without duplicates" do
        expect(subject.participants_for_pagination).to match_array([user, another_user])
      end
    end

    describe "sorting" do
      let(:another_participant_profile) do
        travel_to(10.days.ago) do
          create(:ect_participant_profile)
        end
      end

      context "when no sort parameter is specified" do
        it "returns all records ordered by created_at ascending by default" do
          expect(subject.participants_for_pagination).to eq([another_user, user])
        end
      end

      context "when created_at sort parameter is specified" do
        let(:params) { { sort: "-created_at" } }

        it "returns records in the correct order" do
          expect(subject.participants_for_pagination).to eq([user, another_user])
        end
      end

      context "when updated_at sort parameter is specified" do
        let(:params) { { sort: "updated_at" } }

        it "returns records in the correct order" do
          expect(subject.participants_for_pagination).to eq([user, another_user])
        end
      end
    end
  end

  describe "#participants_from" do
    let(:another_cohort) { create(:cohort, start_year: "2050") }
    let(:another_schedule) { create(:schedule, name: "ECF September 2050", cohort: another_cohort) }
    let!(:another_partnership) { create(:partnership, cohort: another_cohort, lead_provider:) }
    let(:another_participant_profile) { create(:ect_participant_profile) }
    let(:another_induction_programme) { create(:induction_programme, :fip, partnership: another_partnership) }
    let(:another_induction_record) { create(:induction_record, induction_programme: another_induction_programme, participant_profile: another_participant_profile, schedule: another_schedule) }
    let!(:another_user) { another_induction_record.user }

    it "returns all users passed in from query" do
      expect(subject.participants_from(User.all)).to match_array([user, another_user])
    end

    it "returns the correct latest induction record per user" do
      result = subject.participants_from(User.all)

      expect(result.detect { |u| u.id == user.id }.latest_induction_records).to contain_exactly(induction_record.id)
      expect(result.detect { |u| u.id == another_user.id }.latest_induction_records).to contain_exactly(another_induction_record.id)
    end

    context "with multiple providers" do
      let(:another_lead_provider) { create(:cpd_lead_provider, :with_lead_provider).lead_provider }
      let!(:another_partnership) { create(:partnership, cohort: another_cohort, lead_provider: another_lead_provider) }
      let!(:older_induction_record) do
        travel_to(10.days.ago) do
          create(:induction_record, induction_programme:, participant_profile:, induction_status: "changed")
        end
      end

      it "returns all users that belong to a provider" do
        expect(subject.participants_from(User.where(id: user.id))).to match_array([user])
      end

      it "returns the latest induction record" do
        expect(subject.participants_from(User.where(id: user.id)).first.latest_induction_records).to contain_exactly(induction_record.id)
      end
    end

    context "with ect becoming mentor" do
      let(:mentor_participant_profile) { create(:mentor_participant_profile, participant_identity: user.participant_identities.first, teacher_profile: participant_profile.teacher_profile) }
      let(:mentor_induction_programme) { create(:induction_programme, :fip, partnership:) }
      let!(:mentor_induction_record) { create(:induction_record, induction_programme: mentor_induction_programme, participant_profile: mentor_participant_profile, preferred_identity: user.participant_identities.first) }
      let!(:older_induction_record) do
        travel_to(10.days.ago) do
          create(:induction_record, induction_programme:, participant_profile:, induction_status: "changed")
        end
      end
      let!(:older_mentor_induction_record) do
        travel_to(10.days.ago) do
          create(:induction_record, induction_programme: mentor_induction_programme, participant_profile: mentor_participant_profile, preferred_identity: user.participant_identities.first, induction_status: "changed")
        end
      end

      it "returns users without duplicates" do
        expect(subject.participants_from(User.where(id: user.id))).to match_array([user])
      end

      it "returns the latest induction records for the user" do
        expect(subject.participants_from(User.where(id: user.id)).first.latest_induction_records).to contain_exactly(
          induction_record.id,
          mentor_induction_record.id,
        )
      end
    end

    describe "sorting" do
      let(:another_participant_profile) do
        travel_to(10.days.ago) do
          create(:ect_participant_profile)
        end
      end

      context "when no sort parameter is specified" do
        it "returns all records ordered by participant profile created_at ascending by default" do
          expect(subject.participants_from(User.all)).to eq([another_user, user])
        end
      end

      context "when created_at sort parameter is specified" do
        let(:params) { { sort: "-created_at" } }

        it "returns records in the correct order" do
          expect(subject.participants_from(User.all)).to eq([user, another_user])
        end
      end

      context "when updated_at sort parameter is specified" do
        let(:params) { { sort: "updated_at" } }

        it "returns records in the correct order" do
          expect(subject.participants_from(User.all)).to eq([user, another_user])
        end
      end
    end

    context "with preferred identity" do
      let(:preferred_email) { Faker::Internet.email }
      let(:preferred_identity) { create(:participant_identity, :secondary, user: participant_profile.user, email: preferred_email) }
      let!(:induction_record) { create(:induction_record, induction_programme:, participant_profile:, preferred_identity:) }
      let(:user_id) { participant_profile.participant_identity.user_id }

      it "returns the user id of the participant identity" do
        expect(subject.participants_from(User.where(id: user.id)).first.id).to eq(user_id)
      end

      it "returns the preferred email" do
        results = subject.participants_from(User.where(id: user.id))
        expect(results.first.participant_profiles.first.induction_records.first.preferred_identity.email).to eq(preferred_email)
      end
    end

    context "with mentor profile" do
      let(:mentor_participant_profile) { create(:mentor_participant_profile) }
      let(:participant_profile) { create(:ect_participant_profile, mentor_profile_id: mentor_participant_profile.id) }
      let(:user_id) { participant_profile.participant_identity.user_id }
      let(:mentor_user_id) { mentor_participant_profile.participant_identity.user_id }
      let!(:induction_record) { create(:induction_record, induction_programme:, participant_profile:, mentor_profile_id: mentor_participant_profile.id) }

      it "returns the mentor user id" do
        result = subject.participants_from(User.where(id: user.id))
        expect(result.first.participant_profiles.first.mentor.id).to eq(mentor_user_id)
      end

      it "returns the user id" do
        result = subject.participants_from(User.where(id: user.id))
        expect(result.first.id).to eq(user_id)
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
