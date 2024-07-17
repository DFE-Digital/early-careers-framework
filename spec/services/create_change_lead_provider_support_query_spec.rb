# frozen_string_literal: true

require "rails_helper"

RSpec.describe CreateChangeLeadProviderSupportQuery do
  let(:current_user) { create(:user) }
  let(:participant) { instance_double(ParticipantProfile::ECT, full_name: "Test User", id: SecureRandom.uuid) }
  let(:email) { "someone@example.com" }
  let(:school) { instance_double(School, name: "Big School", urn: "123456") }
  let(:start_year) { 2022 }
  let(:current_lead_provider) { instance_double(LeadProvider, name: "Current Lead Provider") }
  let(:new_lead_provider) { instance_double(LeadProvider, name: "New Lead Provider") }

  subject do
    described_class.call(
      current_user:,
      participant:,
      email:,
      school:,
      start_year:,
      current_lead_provider:,
      new_lead_provider:,
    )
  end

  describe ".call" do
    it "creates a support query" do
      expect { subject }.to change { SupportQuery.count }.by(1)
    end

    it "enqueues a support query sync job" do
      expect { subject }.to have_enqueued_job(SupportQuerySyncJob)
    end

    it "adds the correct subject" do
      subject

      expect(SupportQuery.last.subject).to eq("change-participant-lead-provider")
    end

    it "adds the correct message" do
      subject

      expect(SupportQuery.last.message).to eq(
        I18n.t(
          "schools.early_career_teachers.change_lead_provider.support_query.message",
          current_user: current_user.full_name,
          participant: participant.full_name,
          email:,
          school: school.name,
          current_lead_provider: current_lead_provider.name,
          new_lead_provider: new_lead_provider.name,
        ),
      )
    end

    it "adds the correct additional information" do
      subject
      expect(SupportQuery.last.additional_information).to eq(
        I18n.t(
          "schools.early_career_teachers.change_lead_provider.support_query.additional_information",
          academic_year: start_year,
          participant_id: participant.id,
          school: school.name,
          urn: school.urn,
        ),
      )
    end
  end
end
