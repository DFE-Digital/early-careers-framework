# frozen_string_literal: true

require "rails_helper"

RSpec.describe CreateChangeRequestSupportQuery do
  let(:current_user) { build(:user) }
  let(:induction_coordinator_email) { "ian.duck@bigschool.com" }
  let(:induction_coordinator) { build(:user, full_name: "Ian Duck", email: induction_coordinator_email) }
  let(:school_id) { SecureRandom.uuid }
  let(:school) { instance_double(School, id: school_id, name: "Big School", urn: "123456", induction_coordinators: [induction_coordinator]) }
  let(:academic_year) { "2022 to 2023" }
  let(:current_relation) { build(:lead_provider, name: "Current Lead Provider") }
  let(:new_relation) { build(:lead_provider, name: "New Lead Provider") }
  let(:participant) { nil }

  subject do
    described_class.call(
      current_user:,
      participant:,
      school:,
      academic_year:,
      current_relation:,
      new_relation:,
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
          "schools.change_request_support_query.lead_provider.message.cohort",
          academic_year:,
          email: induction_coordinator_email,
          induction_coordinator: induction_coordinator.full_name,
          current_user: current_user.full_name,
          school: school.name,
          current_relation: current_relation.name,
          new_relation: new_relation.name,
        ),
      )
    end

    it "adds the correct additional information" do
      subject
      expect(SupportQuery.last.additional_information).to eq(
        {
          "school_id" => school_id,
          "cohort_year" => academic_year.split.first,
        },
      )
    end

    context "when the change request is specific to a participant" do
      let(:participant_id) { SecureRandom.uuid }
      let(:participant_email) { "participant@example.com" }
      let(:participant) do
        instance_double(
          ParticipantProfile::ECT,
          id: participant_id,
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
            "schools.change_request_support_query.lead_provider.message.participant",
            academic_year:,
            email: participant_email,
            current_user: current_user.full_name,
            participant: participant.full_name,
            school: school.name,
            current_relation: current_relation.name,
            new_relation: new_relation.name,
          ),
        )
      end

      it "adds the correct additional information" do
        subject
        expect(SupportQuery.last.additional_information).to eq(
          {
            "school_id" => school_id,
            "participant_profile_id" => participant_id,
            "cohort_year" => academic_year.split.first,
          },
        )
      end
    end

    context "when the change request is to change delivery partner" do
      let(:current_relation) { build(:delivery_partner, name: "Current Delivery Partner") }
      let(:new_relation) { build(:delivery_partner, name: "New Delivery Partner") }

      it "adds the correct message" do
        subject

        expect(SupportQuery.last.message).to eq(
          I18n.t(
            "schools.change_request_support_query.delivery_partner.message.cohort",
            academic_year:,
            email: induction_coordinator_email,
            induction_coordinator: induction_coordinator.full_name,
            current_user: current_user.full_name,
            school: school.name,
            current_relation: current_relation.name,
            new_relation: new_relation.name,
          ),
        )
      end
    end
  end
end
