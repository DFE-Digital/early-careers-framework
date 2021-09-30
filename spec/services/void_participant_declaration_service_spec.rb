# frozen_string_literal: true

require "rails_helper"

require_relative "../shared/context/service_record_declaration_params"
require_relative "../shared/context/lead_provider_profiles_and_courses"

RSpec.describe VoidParticipantDeclaration do
  include_context "lead provider profiles and courses"
  include_context "service record declaration params"

  context "when voiding declaration" do
    let(:start_date) { ect_profile.schedule.milestones.first.start_date }
    before do
      travel_to start_date + 2.days
      RecordParticipantDeclaration.call(ect_params.merge(declaration_date: (start_date + 2.days).rfc3339))
      travel_to start_date + 3.days
    end

    it "voids a participant declaration" do
      declaration = ParticipantDeclaration.order(:declaration_date).first
      described_class.new(cpd_lead_provider: cpd_lead_provider, id: declaration.id).call
      expect(declaration.reload.voided).to be_truthy
    end

    it "does not void a voided declaration" do
      declaration = ParticipantDeclaration.order(:created_at).last
      described_class.new(cpd_lead_provider: cpd_lead_provider, id: declaration.id).call
      expect {
        described_class.new(cpd_lead_provider: cpd_lead_provider, id: declaration.id).call
      }.to raise_error Api::Errors::InvalidTransitionError
    end

    it "does not void another provider's declaration" do
      declaration = ParticipantDeclaration.order(:created_at).last
      expect {
        described_class.new(cpd_lead_provider: another_lead_provider, id: declaration.id).call
      }.to raise_error ActiveRecord::RecordNotFound
    end

    it "only voids the last declaration" do
      old_declaration = create(:participant_declaration, declaration_date: start_date + 1.day, course_identifier: "ecf-induction", declaration_type: "started", cpd_lead_provider: cpd_lead_provider)
      create(:profile_declaration, participant_declaration: old_declaration, participant_profile: ect_profile)
      expect {
        described_class.new(cpd_lead_provider: cpd_lead_provider, id: old_declaration.id).call
      }.to raise_error Api::Errors::InvalidTransitionError
      expect(old_declaration.reload.voided).to be_falsey

      new_declaration = ParticipantDeclaration.order(declaration_date: :desc).first
      described_class.new(cpd_lead_provider: cpd_lead_provider, id: new_declaration.id).call
      expect(new_declaration.reload.voided).to be_truthy
    end
  end
end
