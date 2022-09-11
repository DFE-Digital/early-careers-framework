# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::ParticipantPresenter do
  let!(:user) { create(:user) }
  let(:school_cohort) { build(:school_cohort) }
  let(:validation_data) { attributes_for(:ecf_participant_validation_data) }
  let(:induction_start_date) { 3.weeks.ago }

  let(:extra_pp_args) { { induction_start_date: } }

  let(:participant_profile) do
    build(:ecf_participant_profile, :with_notes, school_cohort:, user:, **extra_pp_args).tap do |mpp|
      mpp.build_ecf_participant_validation_data(**validation_data)
    end
  end

  subject { Admin::ParticipantPresenter.new(participant_profile:) }

  it { is_expected.to delegate_method(:npq?).to(:participant_profile) }
  it { is_expected.to delegate_method(:ect?).to(:participant_profile) }
  it { is_expected.to delegate_method(:notes).to(:participant_profile) }
  it { is_expected.to delegate_method(:user).to(:participant_profile) }
  it { is_expected.to delegate_method(:full_name).to(:user) }

  describe "#date_of_birth" do
    let(:expected) { validation_data.fetch(:date_of_birth).to_s(:govuk) }

    it "returns the date of birth from the ECF validation data formatted in the GOV.UK style" do
      expect(subject.date_of_birth).to eql(expected)
    end
  end

  describe "#user_start_date" do
    let(:expected) { user.created_at.to_date.to_s(:govuk) }

    it "returns the user's creation date formatted in the GOV.UK style" do
      expect(subject.user_start_date).to eql(expected)
    end
  end

  describe "#induction_start_date" do
    let(:expected) { participant_profile.induction_start_date.to_s(:govuk) }

    it "returns the induction start date from the participant profile" do
      expect(subject.induction_start_date).to eql(expected)
    end
  end

  describe "#associated_email_addresses" do
    let(:fake_identities) { [OpenStruct.new(email: "abc@example.com"), OpenStruct.new(email: "xyz@example.com")] }
    let(:expected) { fake_identities.map(&:email) }

    before { allow(user).to receive(:participant_identities).and_return(fake_identities) }

    it "returns the email addresses from each of the user's identities" do
      expect(subject.associated_email_addresses).to eql(expected)
    end
  end

  describe "induction records" do
    let(:induction_records) do
      build_list(:induction_record, 3) do |induction_record, i|
        induction_record.created_at = i.weeks.ago
      end
    end

    before do
      participant_profile.induction_records << induction_records
    end

    describe "#all_induction_records" do
      it "returns all of the associated induction records" do
        expect(subject.all_induction_records).to match_array(induction_records)
      end
    end

    describe "#latest_induction_record" do
      it "returns the first induction record" do
        expect(subject.latest_induction_record).to eql(induction_records.first)
      end
    end

    describe "#old_induction_records" do
      it "returns all but the first (latest) induction record" do
        expect(subject.old_induction_records).to eql(induction_records.excluding(induction_records.first))
      end
    end
  end

  describe "notes" do
    describe "#notes" do
      it "returns the notes from the participant_profile" do
        expect(subject.notes).to eql(participant_profile.notes)
      end

      it { is_expected.to have_notes }

      context "when there are no notes" do
        before { participant_profile.notes = nil }

        it { is_expected.not_to have_notes }
      end
    end
  end

  describe "#allow_withdrawal?" do
    let(:another_user) { create(:user) }
    let(:fake_policy) { double(withdraw_record?: true) }

    before do
      allow(participant_profile.policy_class).to(
        receive(:new).with(another_user, participant_profile).and_return(fake_policy),
      )
    end

    it "calls #withdraw_record? on the policy class" do
      subject.allow_withdrawal?(another_user)

      expect(fake_policy).to have_received(:withdraw_record?)
    end
  end

  describe "school_cohort" do
    let(:early_induction_record) { build(:induction_record, start_date: 3.weeks.ago, school_cohort: build(:school_cohort)) }
    let(:late_induction_record) { build(:induction_record, start_date: 2.weeks.ago, school_cohort: build(:school_cohort)) }

    it "returns the school cohort from the particiapnt profile" do
      participant_profile.induction_records << early_induction_record
      participant_profile.induction_records << late_induction_record

      expect(subject.school_cohort).to eql(late_induction_record.school_cohort)
    end
  end

  describe "school information" do
    let(:induction_record) { build(:induction_record, start_date: 2.weeks.ago, school_cohort: build(:school_cohort)) }

    before { participant_profile.induction_records << induction_record }

    describe "#school_friendly_id" do
      it "returns the friendly_id from the school attached to the latest induction record's school cohort" do
        expect(subject.school_friendly_id).to eql(induction_record.school_cohort.school.friendly_id)
      end
    end

    describe "#school_name" do
      it "returns the name from the school attached to the latest induction record's school cohort" do
        expect(subject.school_name).to eql(induction_record.school_cohort.school.name)
      end
    end

    describe "#school_urn" do
      it "returns the URN from the school attached to the latest induction record's school cohort" do
        expect(subject.school_urn).to eql(induction_record.school_cohort.school.urn)
      end
    end
  end

  describe "#lead_provider_name" do
    let(:lead_provider) { build(:lead_provider) }
    let(:school_cohort) { build(:school_cohort) }

    before do
      allow(school_cohort).to receive(:lead_provider).and_return(build(:lead_provider))
      participant_profile.induction_records << build(:induction_record, start_date: 2.weeks.ago, school_cohort:)
    end

    it "returns the lead provider from the school cohort" do
      expect(subject.lead_provider_name).to eql(lead_provider.name)
    end
  end

  describe "#mentor_full_name" do
    let(:fake_mentor_name) { "Mr A Mentor" }
    let(:induction_record) { build(:induction_record, start_date: 2.weeks.ago) }

    before do
      allow(induction_record).to receive_message_chain(:mentor_profile, :user, :full_name).and_return(fake_mentor_name)
      participant_profile.induction_records << induction_record
    end

    it "returns the mentor full name from the latest induction record" do
      expect(subject.mentor_full_name).to eql(fake_mentor_name)
    end
  end

  describe "#delivery_partner_name" do
    let(:delivery_partner) { build(:delivery_partner) }
    let(:school_cohort) { build(:school_cohort) }

    before do
      allow(school_cohort).to receive(:delivery_partner).and_return(delivery_partner)
      participant_profile.induction_records << build(:induction_record, start_date: 2.weeks.ago, school_cohort:)
    end

    it "returns the delivery partner name via the school cohort" do
      expect(subject.delivery_partner_name).to eql(delivery_partner.name)
    end
  end
end
