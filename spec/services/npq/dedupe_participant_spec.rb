# frozen_string_literal: true

require "rails_helper"

RSpec.describe NPQ::DedupeParticipant do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider, :with_npq_lead_provider) }
  let(:npq_lead_provider) { cpd_lead_provider.npq_lead_provider }
  let(:npq_application) { create(:npq_application, :eligible_for_funding, npq_lead_provider:) }
  let(:trn) { npq_application&.teacher_reference_number }
  let!(:application_teacher_profile) { travel_to(1.day.from_now) { create(:teacher_profile, user: npq_application.user, trn:) } }
  let!(:primary_teacher_profile) { create(:teacher_profile, trn:) }

  subject(:service) { described_class.new(npq_application:, trn:) }

  def expect_error(attribute, message)
    expect(service).to be_invalid
    expect(service.errors.messages_for(attribute)).to include(message)
  end

  describe "validations" do
    it { is_expected.to be_valid }

    context "when the npq application is missing" do
      let(:application_teacher_profile) {}
      let(:npq_application) {}

      it { expect_error(:npq_application, "The npq application must be present") }
    end

    context "when the trn is missing" do
      let(:trn) {}

      it { expect_error(:trn, "The teacher reference number (TRN) must be present") }
    end

    context "when the application user is missing" do
      before { allow(npq_application).to receive(:user_id).and_return(nil) }

      it { expect_error(:application_user, "The application must have a user") }
    end

    context "when the primary_user_for_trn is missing" do
      before { TeacherProfile.destroy_all }

      it { expect_error(:primary_user_for_trn, "There must be a primary user for this trn") }
    end

    context "when the TRN has not been validated yet" do
      before { npq_application.update!(teacher_reference_number_verified: false) }

      it { expect_error(:trn, "Teacher reference number (TRN) has not been validated") }
    end

    context "when there application_user is the primary_user_for_trn (not a duplicate)" do
      let!(:application_teacher_profile) {}
      let!(:primary_teacher_profile) { create(:teacher_profile, trn:, user: npq_application.user) }

      it { expect_error(:trn, "There is no duplication in this instance") }
    end
  end

  describe "#call" do
    it "calls Identity::Transfer" do
      expect(Identity::Transfer).to receive(:call).with(from_user: application_teacher_profile.user, to_user: primary_teacher_profile.user)

      service.call
    end

    context "when the dedupe has previously been performed" do
      before { described_class.new(npq_application:, trn:).call }

      it { expect { service.call }.not_to change(ParticipantIdChange, :count) }
    end
  end
end
