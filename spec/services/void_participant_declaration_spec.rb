# frozen_string_literal: true

require "rails_helper"

RSpec.describe VoidParticipantDeclaration do
  let(:start_date) { profile.schedule.milestones.first.start_date }
  let(:declaration_date) { start_date + 2.days }
  let(:profile) { create(:ect_participant_profile) }
  let(:school) { profile.school_cohort.school }
  let(:user) { profile.user }
  let(:cpd_lead_provider) { profile.school_cohort.school.partnerships[0].lead_provider.cpd_lead_provider }
  let(:another_cpd_lead_provider) { create(:cpd_lead_provider) }

  before do
    create(:partnership, school: school)
  end

  describe "#call" do
    let(:declaration) do
      create(
        :ect_participant_declaration,
        user: user,
        cpd_lead_provider: cpd_lead_provider,
        declaration_date: declaration_date,
        participant_profile: profile,
      )
    end

    subject do
      described_class.new(cpd_lead_provider: cpd_lead_provider, id: declaration.id)
    end

    it "voids a participant declaration" do
      subject.call
      expect(declaration.reload).to be_voided
    end

    it "does not void a voided declaration" do
      subject.call

      expect {
        subject.call
      }.to raise_error Api::Errors::InvalidTransitionError
    end

    it "cannot not void another provider's declaration" do
      expect {
        described_class.new(cpd_lead_provider: another_cpd_lead_provider, id: declaration.id).call
      }.to raise_error ActiveRecord::RecordNotFound
    end

    context "when there are other declarations" do
      let(:old_declaration) do
        create(
          :participant_declaration,
          :submitted,
          declaration_date: start_date + 1.day,
          course_identifier: "ecf-induction",
          declaration_type: "started",
          cpd_lead_provider: cpd_lead_provider,
          participant_profile: profile,
        )
      end

      before do
        declaration
      end

      it "only voids the last declaration" do
        expect {
          described_class.new(cpd_lead_provider: cpd_lead_provider, id: old_declaration.id).call
        }.to raise_error Api::Errors::InvalidTransitionError

        expect(old_declaration.reload).not_to be_voided

        subject.call
        expect(declaration.reload).to be_voided
      end
    end

    context "when declaration is payable" do
      let(:declaration) do
        create(
          :ect_participant_declaration,
          user: user,
          cpd_lead_provider: cpd_lead_provider,
          declaration_date: declaration_date,
          participant_profile: profile,
          state: "payable",
        )
      end

      it "can be voided" do
        subject.call
        expect(declaration.reload).to be_voided
      end
    end

    context "when declaration is paid" do
      let(:declaration) do
        create(
          :ect_participant_declaration,
          user: user,
          cpd_lead_provider: cpd_lead_provider,
          declaration_date: declaration_date,
          participant_profile: profile,
          state: "paid",
        )
      end

      it "cannot be voided" do
        expect {
          subject.call
        }.to raise_error Api::Errors::InvalidTransitionError
      end
    end
  end
end
