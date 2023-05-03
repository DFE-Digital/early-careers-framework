# frozen_string_literal: true

require "rails_helper"

RSpec.describe ContactSchool do
  subject { described_class.new }

  let!(:school) { create(:school) }
  let!(:school_two) { create(:school) }
  let!(:induction_coordinator_profile) { create(:induction_coordinator_profile, schools: [school]) }
  let!(:user) { create(:user) }

  before(:all) do
    RSpec::Mocks.configuration.verify_partial_doubles = false
  end

  before(:each) do
    allow_any_instance_of(Mail::TestMailer).to receive_message_chain(:response, :id) { "notify_id" }
  end

  after(:all) do
    RSpec::Mocks.configuration.verify_partial_doubles = true
  end

  describe "#sit_email_address_check" do
    it "sends the reminder email" do
      expect { subject.sit_email_address_check([induction_coordinator_profile.user.email]) }
        .to have_enqueued_mail(ParticipantMailer, :sit_contact_address_bounce)
          .with(
            params: {
              induction_coordinator_profile:, school:
            },
            args: [],
          )
    end

    context "the induction coordinator has multiple schools" do
      before do
        induction_coordinator_profile.schools << school_two
      end

      it "sends a reminder to each school" do
        expect { subject.sit_email_address_check([induction_coordinator_profile.user.email]) }
          .to have_enqueued_mail(ParticipantMailer, :sit_contact_address_bounce)
            .with(
              params: {
                induction_coordinator_profile:,
                school:,
              },
              args: [],
            )

        expect { subject.sit_email_address_check([induction_coordinator_profile.user.email]) }
          .to have_enqueued_mail(ParticipantMailer, :sit_contact_address_bounce)
            .with(
              params: {
                induction_coordinator_profile:,
                school: school_two,
              },
              args: [],
            )
      end
    end

    it "does not send unless the user is an induction coordinator" do
      expect { subject.sit_email_address_check([user.email]) }
        .not_to have_enqueued_mail(ParticipantMailer, :sit_contact_address_bounce)
    end

    context "SIT does not have any schools associated with them" do
      before do
        induction_coordinator_profile.update!(schools: [])
      end

      it "it does not try to send an email" do
        expect { subject.sit_email_address_check([induction_coordinator_profile.user.email]) }
          .not_to have_enqueued_mail(ParticipantMailer, :sit_contact_address_bounce)
      end
    end
  end
end
