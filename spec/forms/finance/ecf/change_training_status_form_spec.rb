# frozen_string_literal: true

RSpec.shared_context "changing training status form" do
  subject(:form) { described_class.new(params) }

  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let(:induction_programme) { create(:induction_programme, :fip) }
  let!(:induction_record) { Induction::Enrol.call(participant_profile:, induction_programme:) }
  let(:params) { { participant_profile:, training_status:, reason: "bereavement", induction_record: } }
  let(:training_status) { "deferred" }

  describe "validations" do
    it { is_expected.to validate_inclusion_of(:training_status).in_array(ParticipantProfile.training_statuses.values) }
    it { is_expected.to validate_inclusion_of(:reason).in_array(ParticipantProfile::DEFERRAL_REASONS) }

    context "when the training_status is 'withdrawn'" do
      let(:training_status) { "withdrawn" }

      it { is_expected.to validate_inclusion_of(:reason).in_array(ParticipantProfile::ECF::WITHDRAW_REASONS) }

      context "when the programme type mappings are enabled" do
        before { allow(ProgrammeTypeMappings).to receive(:mappings_enabled?) { true } }

        it { is_expected.to allow_value("switched-to-school-led").for(:reason) }
        it { is_expected.not_to allow_value("school-left-fip").for(:reason) }
      end

      context "when the programme type mappings are disabled" do
        before { allow(ProgrammeTypeMappings).to receive(:mappings_enabled?) { false } }

        it { is_expected.to allow_value("school-left-fip").for(:reason) }
        it { is_expected.not_to allow_value("switched-to-school-led").for(:reason) }
      end
    end
  end

  describe "#reason_options" do
    context "when the current training status is 'deferred'" do
      before { induction_record.training_status = :deferred }

      it "returns the correct reason options" do
        expect(form.reason_options).to eq(
          "withdrawn" => ParticipantProfile::ECF::WITHDRAW_REASONS,
        )
      end
    end

    context "when the current training status is 'withdrawn'" do
      before { induction_record.training_status = :withdrawn }

      it "returns the correct reason options" do
        expect(form.reason_options).to eq(
          "deferred" => ParticipantProfile::DEFERRAL_REASONS,
        )
      end
    end

    context "when the current training status is not 'withdrawn' or 'deferred'" do
      before { induction_record.training_status = :active }

      it "returns the correct reason options" do
        expect(form.reason_options).to eq(
          "withdrawn" => ParticipantProfile::ECF::WITHDRAW_REASONS,
          "deferred" => ParticipantProfile::DEFERRAL_REASONS,
        )
      end
    end

    context "when the programme type mappings are enabled" do
      before { allow(ProgrammeTypeMappings).to receive(:mappings_enabled?) { true } }

      it { expect(form.reason_options["withdrawn"]).to include("switched-to-school-led") }
      it { expect(form.reason_options["withdrawn"]).not_to include("school-left-fip") }
    end

    context "when the programme type mappings are disabled" do
      before { allow(ProgrammeTypeMappings).to receive(:mappings_enabled?) { false } }

      it { expect(form.reason_options["withdrawn"]).not_to include("switched-to-school-led") }
      it { expect(form.reason_options["withdrawn"]).to include("school-left-fip") }
    end
  end

  describe "#save" do
    context "valid params" do
      it "changes training status" do
        expect(form.save).to be true
        expect(participant_profile.reload).to be_training_status_deferred
      end
    end

    context "invalid params" do
      let(:params) { { participant_profile:, training_status: nil, reason: nil } }

      it "does not change training status" do
        expect(form.save).to be false
        expect(participant_profile.reload).to be_training_status_active
      end
    end
  end
end

RSpec.describe Finance::ECF::ChangeTrainingStatusForm, type: :model do
  describe "EarlyCareerTeacher" do
    let!(:participant_declaration) { create(:ect_participant_declaration, participant_profile:, cpd_lead_provider:) }
    let(:user) { create(:participant_identity, :secondary).user }
    let(:participant_profile) { create(:ect, user:, lead_provider: cpd_lead_provider.lead_provider) }

    include_context "changing training status form"
  end

  describe "Mentor" do
    let!(:participant_declaration) { create(:mentor_participant_declaration, participant_profile:, cpd_lead_provider:) }
    let(:user) { create(:participant_identity, :secondary).user }
    let(:participant_profile) { create(:mentor, user:, lead_provider: cpd_lead_provider.lead_provider) }

    include_context "changing training status form"
  end
end
