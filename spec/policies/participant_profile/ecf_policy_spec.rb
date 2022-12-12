# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantProfile::ECFPolicy, :with_default_schedules, type: :policy do
  subject { described_class.new(user, participant_profile) }

  let(:cpd_lead_provider)   { create(:cpd_lead_provider, :with_lead_provider) }
  let(:participant_profile) { create(:ect, lead_provider: cpd_lead_provider.lead_provider) }

  context "being an admin" do
    let(:user) { create(:user, :admin) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:withdraw_record) }
    it { is_expected.to permit_action(:edit_name) }
    it { is_expected.to permit_action(:update_name) }
    it { is_expected.to permit_action(:edit_email) }
    it { is_expected.to permit_action(:update_email) }
    it { is_expected.to permit_action(:update_validation_data) }

    context "after the participant has provided validation data" do
      let(:participant_profile) { create(:ect, :eligible_for_funding, lead_provider: cpd_lead_provider.lead_provider) }

      it { is_expected.to forbid_action(:withdraw_record) }
      it { is_expected.to permit_action(:edit_name) }
      it { is_expected.to permit_action(:update_name) }
      it { is_expected.to permit_action(:edit_email) }
      it { is_expected.to permit_action(:update_email) }
      it { is_expected.to forbid_action(:update_validation_data) }
    end

    context "when the participant is found to be ineligible" do
      let(:participant_profile) { create(:ect, :ineligible, lead_provider: cpd_lead_provider.lead_provider) }

      it { is_expected.to permit_action(:withdraw_record) }
      it { is_expected.to permit_action(:edit_name) }
      it { is_expected.to permit_action(:update_name) }
      it { is_expected.to permit_action(:edit_email) }
      it { is_expected.to permit_action(:update_email) }
      it { is_expected.to permit_action(:update_validation_data) }
    end

    context "when the participant has been withdrawn by the provider" do
      let(:participant_profile) { create(:ect, :eligible_for_funding, lead_provider: cpd_lead_provider.lead_provider) }

      before do
        WithdrawParticipant.new(
          participant_id: participant_profile.teacher_profile.user_id,
          cpd_lead_provider: participant_profile.induction_records.latest.cpd_lead_provider,
          reason: "other",
          course_identifier: "ecf-induction",
        ).call
      end

      it { is_expected.to forbid_action(:withdraw_record) }
      it { is_expected.to permit_action(:edit_name) }
      it { is_expected.to permit_action(:update_name) }
      it { is_expected.to permit_action(:edit_email) }
      it { is_expected.to permit_action(:update_email) }
      it { is_expected.to forbid_action(:update_validation_data) }
    end

    context "with a declaration" do
      before do
        create(:ecf_statement, :output_fee, deadline_date: 2.weeks.from_now, cpd_lead_provider:)
      end

      context "with an eligible declaration" do
        before do
          create(:ect_participant_declaration, participant_profile:, cpd_lead_provider:)
        end

        it { is_expected.to forbid_action(:withdraw_record) }
        it { is_expected.to permit_action(:edit_name) }
        it { is_expected.to permit_action(:update_name) }
        it { is_expected.to permit_action(:edit_email) }
        it { is_expected.to permit_action(:update_email) }
      end

      context "with only voided declarations" do
        before do
          create(:ect_participant_declaration, :voided, participant_profile:, cpd_lead_provider:)
        end

        it { is_expected.to permit_action(:withdraw_record) }
        it { is_expected.to permit_action(:edit_name) }
        it { is_expected.to permit_action(:update_name) }
        it { is_expected.to permit_action(:edit_email) }
        it { is_expected.to permit_action(:update_email) }
      end
    end

    context "with an NPQ application" do
      before do
        create(:npq_application, participant_identity: participant_profile.participant_identity)
      end

      it { is_expected.to permit_action(:withdraw_record) }
      it { is_expected.to permit_action(:edit_name) }
      it { is_expected.to permit_action(:update_name) }
      it { is_expected.to permit_action(:edit_email) }
      it { is_expected.to permit_action(:update_email) }
    end
  end

  context "induction tutor at the correct school" do
    let(:user) { create(:user, :induction_coordinator, schools: [participant_profile.school]) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:withdraw_record) }
    it { is_expected.to forbid_action(:edit_name) }
    it { is_expected.to forbid_action(:update_name) }
    it { is_expected.to forbid_action(:edit_email) }
    it { is_expected.to forbid_action(:update_email) }

    context "after the participant has provided validation data" do
      before do
        create(:ecf_participant_validation_data, participant_profile:)
      end

      it { is_expected.to forbid_action(:withdraw_record) }
      it { is_expected.to permit_action(:edit_name) }
      it { is_expected.to permit_action(:update_name) }
      it { is_expected.to permit_action(:edit_email) }
      it { is_expected.to permit_action(:update_email) }
    end

    context "when the participant is found to be ineligible" do
      let(:participant_profile) { create(:ect, :ineligible, lead_provider: cpd_lead_provider.lead_provider) }

      it { is_expected.to permit_action(:withdraw_record) }
      it { is_expected.to permit_action(:edit_name) }
      it { is_expected.to permit_action(:update_name) }
      it { is_expected.to permit_action(:edit_email) }
      it { is_expected.to permit_action(:update_email) }
    end

    context "with a declaration" do
      let(:participant_profile) { create(:ect, :eligible_for_funding, lead_provider: cpd_lead_provider.lead_provider) }
      before do
        create(:ect_participant_declaration, participant_profile:, cpd_lead_provider:)
      end
      it { is_expected.to forbid_action(:withdraw_record) }
      it { is_expected.to permit_action(:edit_name) }
      it { is_expected.to permit_action(:update_name) }
      it { is_expected.to permit_action(:edit_email) }
      it { is_expected.to permit_action(:update_email) }
    end

    context "with only voided declarations" do
      before do
        create(:ect_participant_declaration, :voided, participant_profile:, cpd_lead_provider:)
      end

      it { is_expected.to permit_action(:withdraw_record) }
      it { is_expected.to forbid_action(:edit_name) }
      it { is_expected.to forbid_action(:update_name) }
      it { is_expected.to forbid_action(:edit_email) }
      it { is_expected.to forbid_action(:update_email) }
    end

    context "with an NPQ application" do
      before do
        create(:npq_application, participant_identity: participant_profile.participant_identity)
      end

      it { is_expected.to permit_action(:withdraw_record) }
      it { is_expected.to forbid_action(:edit_name) }
      it { is_expected.to forbid_action(:update_name) }
      it { is_expected.to forbid_action(:edit_email) }
      it { is_expected.to forbid_action(:update_email) }
    end
  end

  context "induction tutor at a different school" do
    before do
      create(:ecf_participant_validation_data, participant_profile:)
    end

    let(:user) { create(:user, :induction_coordinator) }
    it { is_expected.to forbid_action(:show) }
    it { is_expected.to forbid_action(:withdraw_record) }
    it { is_expected.to forbid_action(:edit_name) }
    it { is_expected.to forbid_action(:update_name) }
    it { is_expected.to forbid_action(:edit_email) }
    it { is_expected.to forbid_action(:update_email) }
  end
end
