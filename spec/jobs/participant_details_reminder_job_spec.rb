# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantDetailsReminderJob, :with_default_schedules do
  let(:participant_profile) { create :ect, sit_validation: true }

  subject { described_class.perform_now(profile_id: participant_profile.id) }

  describe ".schedule" do
    it "schedules the reminder email" do
      freeze_time
      expect {
        described_class.schedule(participant_profile)
      }.to have_enqueued_job(described_class)
        .with(profile_id: participant_profile.id)
        .at(described_class::REMIND_TIME.from_now)
    end
  end

  describe "#perform" do
    before do
      freeze_time
      allow(described_class).to receive(:schedule)
    end

    context "when participant is not withdrawn and haven't submit their validation details" do
      it "enqueues reminder email" do
        expect { subject }.to have_enqueued_mail(ParticipantMailer, :add_details_reminder)
          .with(participant_profile:)
      end

      it "reschedules self" do
        subject

        expect(described_class).to have_received(:schedule).with(participant_profile)
      end

      it "updates request_for_details_sent_at" do
        expect { subject }
          .to change { participant_profile.reload.request_for_details_sent_at }.to(Time.zone.now)
      end
    end

    context "when participant has been withdrawn" do
      let(:participant_profile) { create(:ect, :withdrawn, sit_validation: true) }

      it "does not enqueue reminder email" do
        expect { subject }.to_not have_enqueued_mail(ParticipantMailer, :add_details_reminder)
      end

      it "does not reschedule self" do
        subject

        expect(described_class).not_to have_received(:schedule).with(participant_profile)
      end

      it "updates request_for_details_sent_at" do
        expect { subject }
          .not_to change { participant_profile.reload.request_for_details_sent_at }
      end
    end

    context "when participant has submitted their details" do
      let(:participant_profile) { create(:ect, :eligible_for_funding, sit_validation: true) }

      it "does not enqueue reminder email" do
        expect { subject }.to_not have_enqueued_mail(ParticipantMailer, :add_details_reminder)
      end

      it "does not reschedule self" do
        subject

        expect(described_class).not_to have_received(:schedule).with(participant_profile)
      end

      it "updates request_for_details_sent_at" do
        expect { subject }
          .not_to change { participant_profile.reload.request_for_details_sent_at }
      end
    end
  end
end
