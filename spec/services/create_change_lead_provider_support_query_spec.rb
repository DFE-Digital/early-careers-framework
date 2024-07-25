# frozen_string_literal: true

require "rails_helper"

RSpec.describe CreateChangeLeadProviderSupportQuery do
  let(:current_user) { build(:user) }
  let(:induction_coordinator_email) { "ian.duck@bigschool.com" }
  let(:induction_coordinator) { build(:user, full_name: "Ian Duck", email: induction_coordinator_email) }
  let(:school) { instance_double(School, name: "Big School", urn: "123456", induction_coordinators: [induction_coordinator]) }
  let(:academic_year) { "2022 to 2023" }
  let(:current_lead_provider) { instance_double(LeadProvider, name: "Current Lead Provider") }
  let(:new_lead_provider) { instance_double(LeadProvider, name: "New Lead Provider") }
  let(:participant) { nil }

  subject do
    described_class.call(
      current_user:,
      participant:,
      school:,
      academic_year:,
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

      expect(SupportQuery.last.subject).to eq("change-cohort-lead-provider")
    end

    it "adds the correct message" do
      subject

      expect(SupportQuery.last.message).to eq(
        I18n.t(
          "schools.change_lead_provider.support_query.message.cohort",
          academic_year:,
          email: induction_coordinator_email,
          induction_coordinator: induction_coordinator.full_name,
          current_user: current_user.full_name,
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
          "schools.change_lead_provider.support_query.additional_information",
          academic_year:,
          school: school.name,
          urn: school.urn,
        ),
      )
    end

    context "when the change request is specific to a participant" do
      let(:participant_email) { "participant@example.com" }
      let(:participant) do
        instance_double(
          ParticipantProfile::ECT,
          full_name: "Test User",
          user: create(:user, email: participant_email),
        )
      end

      it "adds the correct subject" do
        subject

        expect(SupportQuery.last.subject).to eq("change-participant-lead-provider")
      end

      it "adds the correct message" do
        subject

        expect(SupportQuery.last.message).to eq(
          I18n.t(
            "schools.change_lead_provider.support_query.message.participant",
            academic_year:,
            email: participant_email,
            current_user: current_user.full_name,
            participant: participant.full_name,
            school: school.name,
            current_lead_provider: current_lead_provider.name,
            new_lead_provider: new_lead_provider.name,
          ),
        )
      end
    end
  end
end
