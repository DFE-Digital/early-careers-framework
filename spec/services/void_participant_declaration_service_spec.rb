# frozen_string_literal: true

require "rails_helper"

require_relative "../shared/context/service_record_declaration_params.rb"
require_relative "../shared/context/lead_provider_profiles_and_courses.rb"

RSpec.describe VoidParticipantDeclaration do
  include_context "lead provider profiles and courses"
  include_context "service record declaration params"

  context "when voiding declaration" do
    let(:start_date) { ect_profile.schedule.milestones.first.start_date }
    before do
      travel_to start_date + 2.days
      RecordParticipantDeclaration.call(ect_params)
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
      }.to raise_error ActiveRecord::RecordInvalid
    end

    it "only voids the last declaration" do
      old_declaration = create(:participant_declaration, declaration_date: start_date + 1.day, course_identifier: "ecf-induction", declaration_type: "started")
      create(:profile_declaration, participant_declaration: old_declaration, participant_profile: ect_profile)
      expect {
        described_class.new(cpd_lead_provider: cpd_lead_provider, id: old_declaration.id).call
      }.to raise_error ActiveRecord::RecordInvalid
      expect(old_declaration.reload.voided).to be_falsey

      new_declaration = ParticipantDeclaration.order(:declaration_date).first
      described_class.new(cpd_lead_provider: cpd_lead_provider, id: new_declaration.id).call
      expect(new_declaration.reload.voided).to be_truthy
    end
  end
end
