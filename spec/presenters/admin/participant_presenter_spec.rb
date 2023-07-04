# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Admin::ParticipantPresenter) do
  let(:partnership) { FactoryBot.create(:seed_partnership, :valid) }
  let(:induction_programme) { FactoryBot.create(:seed_induction_programme, :valid, partnership:) }
  let(:school_cohort) { induction_programme.school_cohort }

  let(:scenario) do
    NewSeeds::Scenarios::Participants::Ects::Ect.new(school_cohort:)
      .build
      .with_induction_record(induction_programme:, start_date: 2.weeks.ago)
      .with_induction_record(induction_programme:, start_date: 3.weeks.ago)
  end
  let(:participant_profile) { scenario.participant_profile }

  subject { Admin::ParticipantPresenter.new(participant_profile) }

  describe "initialisation" do
    it "is initialised with a participant profile" do
      expect(subject).to be_a(Admin::ParticipantPresenter)
    end
  end

  describe "delegation" do
    it { is_expected.to delegate_method(:id).to(:participant_profile) }
    it { is_expected.to delegate_method(:participant_identity).to(:participant_profile) }
    it { is_expected.to delegate_method(:training_status).to(:participant_profile) }
    it { is_expected.to delegate_method(:notes).to(:participant_profile) }
    it { is_expected.to delegate_method(:notes?).to(:participant_profile) }
    it { is_expected.to delegate_method(:ect?).to(:participant_profile) }
    it { is_expected.to delegate_method(:mentor?).to(:participant_profile) }
    it { is_expected.to delegate_method(:ecf_participant_validation_data).to(:participant_profile) }
    it { is_expected.to delegate_method(:ecf_participant_eligibility).to(:participant_profile) }
    it { is_expected.to delegate_method(:teacher_profile).to(:participant_profile) }

    it { is_expected.to delegate_method(:full_name).to(:user) }
    it { is_expected.to delegate_method(:email).to(:user) }
    it { is_expected.to delegate_method(:participant_identities).to(:user) }

    it { is_expected.to delegate_method(:user_id).to(:participant_identity) }

    it { is_expected.to delegate_method(:trn).to(:teacher_profile) }
  end

  describe "methods" do
    describe "#relevant_induction_record" do
      let(:fake_findby) { instance_double(Induction::FindBy, call: true) }
      before { allow(Induction::FindBy).to receive(:new).with(any_args).and_return(fake_findby) }

      it "uses Induction::FindBy to retrieve the relevant record" do
        subject.relevant_induction_record

        expect(Induction::FindBy).to have_received(:new).with(participant_profile:).once
        expect(fake_findby).to have_received(:call).once
      end

      describe "#lead_provider_name" do
        let(:dummy_lp) { FactoryBot.build(:seed_lead_provider) }
        let(:dummy_induction_record) { instance_double(InductionRecord) }

        before do
          allow(subject).to receive(:relevant_induction_record).and_return(dummy_induction_record)
          allow(dummy_induction_record).to receive(:lead_provider_name).and_return(dummy_lp.name)
        end

        it "returns the lead_provider_name via induction record and induction programme" do
          expect(subject.lead_provider_name).to eql(dummy_lp.name)
        end
      end

      describe "#delivery_partner_name" do
        let(:dummy_dp) { FactoryBot.build(:seed_delivery_partner) }
        let(:dummy_induction_record) { instance_double(InductionRecord) }

        before do
          allow(subject).to receive(:relevant_induction_record).and_return(dummy_induction_record)
          allow(dummy_induction_record).to receive(:delivery_partner_name).and_return(dummy_dp.name)
        end

        it "returns the delivery_partner_name via induction record and induction programme" do
          expect(subject.delivery_partner_name).to eql(dummy_dp.name)
        end
      end
    end

    describe "#school_cohort" do
      it "returns the school cohort via relevant induction record" do
        expect(subject.school_cohort).to eql(subject.relevant_induction_record.school_cohort)
      end

      describe "#school" do
        it "returns the school via relevant induction record and school cohort" do
          expect(subject.school).to eql(subject.relevant_induction_record.school_cohort.school)
        end

        describe "#school_name" do
          it "returns the school_name school" do
            expect(subject.school_name).to eql(subject.relevant_induction_record.school_cohort.school.name)
          end
        end

        describe "#school_urn" do
          it "returns the school_urn school" do
            expect(subject.school_urn).to eql(subject.relevant_induction_record.school_cohort.school.urn)
          end
        end

        describe "#school_friendly_id" do
          it "returns the school_friendly_id school" do
            expect(subject.school_friendly_id).to eql(subject.relevant_induction_record.school_cohort.school.friendly_id)
          end
        end
      end

      describe "#cohort" do
        it "returns the cohort via relevant induction record and school cohort" do
          expect(subject.cohort).to eql(subject.relevant_induction_record.school_cohort.cohort)
        end
      end

      describe "#start_year" do
        it "returns the start_year via induction record, school cohort and cohort" do
          expect(subject.start_year).to eql(subject.relevant_induction_record.school_cohort.cohort.start_year)
        end
      end

      describe "#school_lead_provider_name" do
        let(:dummy_lp) { FactoryBot.build(:seed_lead_provider) }

        before { allow_any_instance_of(SchoolCohort).to receive(:lead_provider).and_return(dummy_lp) }

        it "returns the lead_provider_name via school cohort and school" do
          expect(subject.school_lead_provider_name).to eql(dummy_lp.name)
        end
      end

      describe "#school_delivery_partner_name" do
        let(:dummy_dp) { FactoryBot.build(:seed_delivery_partner) }

        before { allow_any_instance_of(SchoolCohort).to receive(:delivery_partner).and_return(dummy_dp) }

        it "returns the delivery_partner_name via school cohort and school" do
          expect(subject.school_delivery_partner_name).to eql(dummy_dp.name)
        end
      end

      describe "#appropriate_body_name" do
        let(:dummy_ab) { FactoryBot.build(:seed_appropriate_body) }

        before { allow_any_instance_of(SchoolCohort).to receive(:appropriate_body).and_return(dummy_ab) }

        it "returns the appropiate_body_name via induction record and school cohort" do
          expect(subject.appropriate_body_name).to eql(dummy_ab.name)
        end
      end
    end

    describe "#induction_records" do
      describe "#all_induction_records" do
        it "returns all of the participant's induction records" do
          expect(subject.all_induction_records.pluck(:id)).to match_array(participant_profile.induction_records.pluck(:id))
        end
      end

      describe "#historical_induction_records" do
        it "returns all of the participant's induction records except the most recent" do
          all = participant_profile.induction_records.order(start_date: :desc, created_at: :desc)

          expected = all.excluding(all.first)

          expect(subject.historical_induction_records.pluck(:id)).to match_array(expected.map(&:id))
        end

        context "when participant is missing their induction records" do
          before { participant_profile.induction_records.destroy_all }

          it "returns an empty array" do
            expect(subject.historical_induction_records).to be_empty
          end
        end
      end
    end

    describe "#has_mentor?" do
      let(:fake_mentor) { instance_double(ParticipantProfile::Mentor, present?: true) }
      let(:fake_induction_record) { instance_double(InductionRecord, mentor: fake_mentor) }
      before { allow(subject).to receive(:relevant_induction_record).and_return(fake_induction_record) }

      it "checks mentor presence via the induction record" do
        subject.has_mentor?

        expect(fake_induction_record).to have_received(:mentor).once
        expect(fake_mentor).to have_received(:present?).once
      end
    end

    describe "via the mentor_profile" do
      let(:fake_mentor_profile) { instance_double(ParticipantProfile::Mentor, present?: true, full_name: "Bertie Mentorson") }

      before { allow(subject).to receive(:mentor_profile).and_return(fake_mentor_profile) }

      describe "#is_mentor?" do
        it "checks mentor presence via the mentor_profile" do
          subject.is_mentor?

          expect(fake_mentor_profile).to have_received(:present?).once
        end
      end

      describe "#mentor_full_name" do
        it "retrieves the full name via mentor_profile" do
          actual = subject.mentor_full_name

          expect(fake_mentor_profile).to have_received(:full_name).once
          expect(actual).to eql(fake_mentor_profile.full_name)
        end
      end

      describe "#mentor_profile" do
        it "returns the mentor profile" do
          expect(subject.mentor_profile).to eql(fake_mentor_profile)
        end
      end
    end

    describe "#user_created_at" do
      it "returns the user's creation timestamp in a GOV.UK format" do
        expect(subject.user_created_at).to eql(scenario.user.created_at.to_date.to_formatted_s(:govuk))
      end
    end

    describe "#mentees_by_school" do
      let!(:mentor_profile) { FactoryBot.create(:seed_mentor_participant_profile, :valid) }
      let!(:mentee_induction_records) { FactoryBot.create_list(:seed_induction_record, 2, :valid, mentor_profile:) }

      subject { Admin::ParticipantPresenter.new(mentor_profile) }

      it("returns a hash") { expect(subject.mentees_by_school).to be_a(Hash) }
      it("contains the right data") do
        mentee_induction_records.map(&:participant_profile).each do |mentee|
          expect(subject.mentees_by_school[mentee.school]).to include(mentee)
        end
      end
    end

    describe "#declarations" do
      let!(:declarations) { FactoryBot.create_list(:seed_ecf_participant_declaration, 2, :valid, participant_profile:) }

      it "returns the declarations belonging to the participant" do
        expect(subject.declarations).to match_array(declarations)
      end
    end

    describe "#validation_data" do
      let!(:validation_data) { FactoryBot.create(:seed_ecf_participant_validation_data, :valid, participant_profile:) }

      it "returns the validation_data belonging to the participant" do
        expect(subject.validation_data).to eql(validation_data)
      end
    end

    describe "#eligibility_data" do
      let!(:eligibility_data) { FactoryBot.create(:seed_ecf_participant_eligibility, :valid, participant_profile:) }

      it "returns the validation_data belonging to the participant" do
        expect(subject.eligibility_data).to eql(eligibility_data)
      end
    end
  end
end
