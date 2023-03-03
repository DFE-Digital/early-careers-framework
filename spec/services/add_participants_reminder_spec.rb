# frozen_string_literal: true

require "rails_helper"

RSpec.describe AddParticipantsReminder do
  subject(:add_participants_reminder) { described_class.new(cohort:) }
  let!(:cohort) { create(:cohort, :next) }

  let!(:school) { create(:school) }
  let!(:school_two) { create(:school) }
  let!(:school_cohort) { create(:school_cohort, :fip, school:, cohort:) }
  let!(:school_two_cohort) { create(:school_cohort, :cip, school: school_two, cohort:) }

  let!(:induction_coordinator_profile) { create(:induction_coordinator_profile, schools: [school]) }
  let!(:induction_coordinator_profile_school_two) { create(:induction_coordinator_profile, schools: [school_two]) }

  before(:all) do
    RSpec::Mocks.configuration.verify_partial_doubles = false
  end

  before(:each) do
    allow_any_instance_of(Mail::TestMailer).to receive_message_chain(:response, :id) { "notify_id" }
  end

  after(:all) do
    RSpec::Mocks.configuration.verify_partial_doubles = true
  end

  describe "#fip_register_participants_reminder" do
    it "sends the reminder email" do
      expect { add_participants_reminder.fip_register_participants_reminder }
        .to have_enqueued_mail(ParticipantMailer, :fip_register_participants_reminder)
          .with(
            params: {
              induction_coordinator_profile:,
              school_name: school.name,
            },
            args: [],
          )
    end

    context "with an induction profile that has already received the email" do
      before do
        create(:email, associated_with: [induction_coordinator_profile], tags: %w[fip_register_participants_reminder])
      end

      it "does not send the email again" do
        expect { add_participants_reminder.fip_register_participants_reminder }.not_to have_enqueued_mail(ParticipantMailer, :fip_register_participants_reminder)
      end
    end

    context "where the school has already added participants" do
      before { create :ect_participant_profile, school_cohort: }

      it "does not send the email" do
        expect { add_participants_reminder.fip_register_participants_reminder }.not_to have_enqueued_mail(ParticipantMailer, :fip_register_participants_reminder)
      end
    end
  end

  describe "#cip_register_participants_reminder" do
    it "sends the reminder email" do
      expect { add_participants_reminder.cip_register_participants_reminder }
        .to have_enqueued_mail(ParticipantMailer, :cip_register_participants_reminder)
          .with(
            params: {
              induction_coordinator_profile: induction_coordinator_profile_school_two,
              school_name: school_two.name,
            },
            args: [],
          )
    end

    context "with an induction profile that has already received the email" do
      before do
        create(:email, associated_with: [induction_coordinator_profile_school_two], tags: %w[cip_register_participants_reminder])
      end

      it "does not send the email again" do
        expect { add_participants_reminder.cip_register_participants_reminder }
          .not_to have_enqueued_mail(ParticipantMailer, :cip_register_participants_reminder)
      end
    end

    context "where the school has already added participants" do
      before { create :ect_participant_profile, school_cohort: school_two_cohort }

      it "does not send the email" do
        expect { add_participants_reminder.cip_register_participants_reminder }
          .not_to have_enqueued_mail(ParticipantMailer, :cip_register_participants_reminder)
      end
    end
  end
end
