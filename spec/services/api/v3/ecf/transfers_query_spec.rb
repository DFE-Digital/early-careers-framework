# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V3::ECF::TransfersQuery do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let(:lead_provider) { cpd_lead_provider.lead_provider }
  let(:cohort) { Cohort.current || create(:cohort, :current) }
  let(:partnership) { create(:partnership, lead_provider:, cohort:) }
  let(:participant_profile) { create(:ect_participant_profile) }
  let(:induction_programme) { create(:induction_programme, :fip, partnership:) }
  let!(:another_induction_record) { create(:induction_record, induction_programme:, participant_profile:) }

  let(:params) { {} }

  subject { described_class.new(lead_provider:, params:) }

  describe "#users" do
    context "with no participant school transfers" do
      it "returns no users" do
        expect(subject.users).to be_empty
      end
    end

    context "with participant FIP school transfers keeping original provider" do
      let!(:induction_record) do
        NewSeeds::Scenarios::Participants::Transfers::FipToFipKeepingOriginalTrainingProvider
          .new(lead_provider_from: lead_provider)
          .build
      end

      let(:user) { induction_record.preferred_identity.user }

      it "returns all users with transfers" do
        expect(subject.users).to contain_exactly(user)
      end
    end

    context "with participant FIP school transfers changing from lead provider" do
      let!(:induction_record) do
        NewSeeds::Scenarios::Participants::Transfers::FipToFipChangingTrainingProvider
          .new(lead_provider_from: lead_provider)
          .build
      end

      let(:user) { induction_record.preferred_identity.user }

      it "returns all users with transfers" do
        expect(subject.users).to contain_exactly(user)
      end
    end

    context "with participant FIP school transfers changing to lead provider" do
      let!(:induction_record) do
        NewSeeds::Scenarios::Participants::Transfers::FipToFipChangingTrainingProvider
          .new(lead_provider_to: lead_provider)
          .build
      end

      let(:user) { induction_record.preferred_identity.user }

      it "returns all users with transfers" do
        expect(subject.users).to contain_exactly(user)
      end
    end

    context "when transferred ECT participant becomes mentor" do
      let!(:induction_record) do
        NewSeeds::Scenarios::Participants::Transfers::FipToFipChangingTrainingProvider
          .new(lead_provider_to: lead_provider)
          .build
      end

      let(:mentor_school) do
        NewSeeds::Scenarios::Schools::School
          .new
          .build
          .with_partnership_in(cohort:, lead_provider:)
          .chosen_fip_and_partnered_in(cohort:)
      end

      let!(:mentor) do
        NewSeeds::Scenarios::Participants::Mentors::MentorWithNoEcts
          .new(
            school_cohort: mentor_school.school_cohort,
            participant_identity: induction_record.preferred_identity,
            teacher_profile: induction_record.participant_profile.teacher_profile,
          )
          .build(schedule: Finance::Schedule::ECF.default_for(cohort:))
          .with_validation_data
          .with_eligibility
          .with_induction_record(induction_programme: mentor_school.induction_programme)
      end

      let(:user) { induction_record.preferred_identity.user }

      it "returns all users with transfers" do
        expect(subject.users).to contain_exactly(user)
      end
    end

    context "with participant CIP to FIP school transfers" do
      let!(:induction_record) do
        NewSeeds::Scenarios::Participants::Transfers::CipToFip
          .new(lead_provider_to: lead_provider)
          .build
      end

      let(:user) { induction_record.preferred_identity.user }

      it "returns all users with transfers" do
        expect(subject.users).to contain_exactly(user)
      end
    end

    context "with participant FIP to CIP school transfers" do
      let!(:induction_record) do
        NewSeeds::Scenarios::Participants::Transfers::FipToCip
          .new(lead_provider_from: lead_provider)
          .build
      end

      let(:user) { induction_record.preferred_identity.user }

      it "returns all users with transfers" do
        expect(subject.users).to contain_exactly(user)
      end
    end

    context "with other providers leaving induction records" do
      let(:another_cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
      let(:another_lead_provider) { another_cpd_lead_provider.lead_provider }
      let(:another_partnership) { create(:partnership, lead_provider: another_lead_provider, cohort:) }
      let(:another_induction_programme) { create(:induction_programme, :fip, partnership: another_partnership) }
      let!(:leaving_induction_record) { create(:induction_record, :leaving, induction_programme: another_induction_programme, participant_profile:) }
      let!(:changing_induction_record) { create(:induction_record, induction_status: "changed", induction_programme: another_induction_programme, participant_profile:) }

      it "returns no users" do
        expect(subject.users).to be_empty
      end
    end

    context "with updated_since filter" do
      context "with valid date" do
        let!(:induction_record) do
          NewSeeds::Scenarios::Participants::Transfers::FipToFipKeepingOriginalTrainingProvider
            .new(lead_provider_from: lead_provider)
            .build
        end
        let(:user) { induction_record.preferred_identity.user }

        let!(:another_transfer_induction_record) do
          NewSeeds::Scenarios::Participants::Transfers::FipToFipKeepingOriginalTrainingProvider
            .new(lead_provider_from: lead_provider)
            .build
        end
        let(:another_user) { another_transfer_induction_record.preferred_identity.user }
        let(:params) { { filter: { updated_since: 1.day.ago.iso8601 } } }

        before { another_user.update(updated_at: 4.days.ago.iso8601) }

        it "returns all users for the specific updated_since filter" do
          expect(subject.users).to contain_exactly(user)
        end
      end

      context "with invalid date" do
        let(:params) { { filter: { updated_since: "invalid" } } }

        it "raises an error" do
          expect { subject.users }.to raise_error(Api::Errors::InvalidDatetimeError)
        end
      end
    end
  end
end
