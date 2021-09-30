# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantDetailsReminderJob do
  let(:participant_profile) { create :participant_profile, :ecf }

  describe ".schedule" do
    let(:participant_profile) { create :participant_profile, :ecf }

    it "schedules the reminder email" do
      freeze_time
      described_class.schedule(participant_profile)

      expect(described_class).to be_enqueued.with(profile_id: participant_profile.id).at(described_class::REMIND_TIME.from_now)
    end
  end

  describe "#perform" do
    subject { -> { described_class.perform_now(profile_id: :participant_profile) } }

    before do
      freeze_time
      allow(described_class).to receive(:schedule)
    end

    context "when participant is not withdrawn and haven't submit their validation details" do
      it "enqueues reminder email" do
        described_class.perform_now(profile_id: participant_profile.id)
        expect(ParticipantMailer).to delay_email_delivery_of(:add_details_reminder).with(participant_profile: participant_profile)
      end

      it "reschedules self" do
        described_class.perform_now(profile_id: participant_profile.id)
        expect(described_class).to have_received(:schedule).with(participant_profile)
      end

      it "updates request_for_details_sent_at" do
        expect { described_class.perform_now(profile_id: participant_profile.id) }
          .to change { participant_profile.reload.request_for_details_sent_at }.to(Time.zone.now)
      end
    end

    context "when participant has been withdrawn" do
      let(:participant_profile) { create :participant_profile, :ecf, :withdrawn }

      it "does not enqueue reminder email" do
        expect(ParticipantMailer).not_to delay_email_delivery_of(:add_details_reminder)
      end

      it "does not reschedule self" do
        expect(described_class).not_to have_received(:schedule).with(participant_profile)
      end

      it "updates request_for_details_sent_at" do
        expect { described_class.perform_now(profile_id: participant_profile.id) }
          .not_to change { participant_profile.reload.request_for_details_sent_at }
      end
    end

    context "when participant has submitted their details" do
      let(:participant_profile) { create :participant_profile, :ecf }

      before do
        create(:ecf_participant_validation_data, participant_profile: participant_profile)
      end

      it "does not enqueue reminder email" do
        expect(ParticipantMailer).not_to delay_email_delivery_of(:add_details_reminder)
      end

      it "does not reschedule self" do
        expect(described_class).not_to have_received(:schedule).with(participant_profile)
      end

      it "updates request_for_details_sent_at" do
        expect { described_class.perform_now(profile_id: participant_profile.id) }
          .not_to change { participant_profile.reload.request_for_details_sent_at }
      end
    end
  end
end
