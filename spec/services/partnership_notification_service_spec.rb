# frozen_string_literal: true

RSpec.describe PartnershipNotificationService do
  subject(:partnership_notification_service) { described_class.new }

  let!(:lead_provider) { create(:lead_provider) }
  let!(:delivery_partner) { create(:delivery_partner) }
  let!(:cohort) { Cohort.current || create(:cohort, :current) }

  before do
    ProviderRelationship.create!(lead_provider:, delivery_partner:, cohort:)
  end

  let(:school) { create(:school) }
  let(:partnership) do
    create(:partnership, lead_provider:, delivery_partner:, cohort:, school:)
  end
  let(:partnership_notification_email) { partnership.partnership_notification_emails.last }
  let(:notify_id) { Faker::Alphanumeric.alphanumeric(number: 16) }

  describe "#notify" do
    context "when the school has no induction coordinator" do
      let(:contact_email) { Faker::Internet.email }
      let(:school) { create(:school, primary_contact_email: contact_email) }

      before(:all) do
        RSpec::Mocks.configuration.verify_partial_doubles = false
      end

      after(:all) do
        RSpec::Mocks.configuration.verify_partial_doubles = true
      end

      it "emails the school primary contact" do
        expect(SchoolMailer).to receive(:school_partnership_notification_email).with(
          hash_including(
            partnership:,
            nominate_url: String,
            challenge_url: String,
            recipient: contact_email,
          ),
        ).and_call_original
        allow_any_instance_of(Mail::TestMailer).to receive_message_chain(:response, :id) { notify_id }

        partnership_notification_service.notify(partnership)

        expect(partnership_notification_email.sent_to).to eql contact_email
        expect(partnership_notification_email.notify_id).to eql notify_id
      end
    end

    context "when the school has an induction coordinator" do
      let(:contact_email) { Faker::Internet.email }
      let(:school) { create(:school) }
      let!(:coordinator) { create(:user, :induction_coordinator, schools: [school], email: contact_email) }

      before(:all) do
        RSpec::Mocks.configuration.verify_partial_doubles = false
      end

      after(:all) do
        RSpec::Mocks.configuration.verify_partial_doubles = true
      end

      it "emails the induction coordinator" do
        expect(SchoolMailer).to receive(:coordinator_partnership_notification_email).with(
          hash_including(
            partnership:,
            coordinator:,
            sign_in_url: String,
            challenge_url: String,
          ),
        ).and_call_original
        allow_any_instance_of(Mail::TestMailer).to receive_message_chain(:response, :id) { notify_id }

        partnership_notification_service.notify(partnership)

        expect(partnership_notification_email.sent_to).to eql contact_email
        expect(partnership_notification_email.notify_id).to eql notify_id
      end
    end
  end

  describe "#send_reminder" do
    context "when the school has no induction coordinator" do
      let(:contact_email) { Faker::Internet.email }
      let(:school) { create(:school, primary_contact_email: contact_email) }

      before(:all) do
        RSpec::Mocks.configuration.verify_partial_doubles = false
      end

      after(:all) do
        RSpec::Mocks.configuration.verify_partial_doubles = true
      end

      it "emails the school primary contact" do
        expect(SchoolMailer).to receive(:school_partnership_notification_email).with(
          hash_including(
            partnership:,
            nominate_url: String,
            challenge_url: String,
            recipient: contact_email,
          ),
        ).and_call_original
        allow_any_instance_of(Mail::TestMailer).to receive_message_chain(:response, :id) { notify_id }

        partnership_notification_service.send_reminder(partnership)

        expect(partnership_notification_email.sent_to).to eql contact_email
        expect(partnership_notification_email.notify_id).to eql notify_id
      end
    end

    context "when the school has an induction coordinator" do
      let(:contact_email) { Faker::Internet.email }
      let(:school) { create(:school) }
      let!(:coordinator) { create(:user, :induction_coordinator, schools: [school], email: contact_email) }
      before(:all) do
        RSpec::Mocks.configuration.verify_partial_doubles = false
      end

      after(:all) do
        RSpec::Mocks.configuration.verify_partial_doubles = true
      end

      it "emails the induction coordinator" do
        expect(SchoolMailer).to receive(:coordinator_partnership_notification_email).with(
          hash_including(
            partnership:,
            coordinator:,
            sign_in_url: String,
            challenge_url: String,
          ),
        ).and_call_original
        allow_any_instance_of(Mail::TestMailer).to receive_message_chain(:response, :id) { notify_id }

        partnership_notification_service.send_reminder(partnership)

        expect(partnership_notification_email.sent_to).to eql contact_email
        expect(partnership_notification_email.notify_id).to eql notify_id
      end
    end
  end

  describe "#send_invite_sit_reminder_to_partnered_schools" do
    let(:contact_email) { Faker::Internet.email }
    let(:school) do
      create(:school_cohort, :fip).school.tap do |s|
        s.update!(primary_contact_email: contact_email)
      end
    end

    before(:all) do
      RSpec::Mocks.configuration.verify_partial_doubles = false
    end

    after(:all) do
      RSpec::Mocks.configuration.verify_partial_doubles = true
    end

    it "emails schools that are fip partnered with no SIT, and extends the challenge deadline by 2 weeks" do
      expect(SchoolMailer).to receive(:partnered_school_invite_sit_email).with(
        hash_including(
          school:,
          lead_provider_name: partnership.lead_provider.name,
          delivery_partner_name: partnership.delivery_partner.name,
          challenge_url: a_string_including("utm_campaign=partnered-invite-sit-reminder&utm_medium=email&utm_source=partnered-invite-sit-reminder"),
          nominate_url: a_string_including("utm_campaign=partnered-invite-sit-reminder&utm_medium=email&utm_source=partnered-invite-sit-reminder"),
          recipient: contact_email,
        ),
      ).and_call_original
      allow_any_instance_of(Mail::TestMailer).to receive_message_chain(:response, :id) { notify_id }

      Timecop.freeze do
        partnership_notification_service.send_invite_sit_reminder_to_partnered_schools

        expect(partnership_notification_email.sent_to).to eq(contact_email)
        expect(partnership_notification_email.notify_id).to eq(notify_id)
        expect(partnership_notification_email.email_type).to eq("nominate_sit_email")
        expect(partnership_notification_email.reload.challenge_deadline).to be_within(1.second).of(Date.parse("Oct 31 2021").end_of_day)
      end
    end

    it "doesn't email schools that aren't partnered" do
      expect(SchoolMailer).to_not receive(:partnered_school_invite_sit_email)
      partnership_notification_service.send_invite_sit_reminder_to_partnered_schools
    end

    it "doesn't email schools that aren't fip" do
      expect(SchoolMailer).to_not receive(:partnered_school_invite_sit_email)
      school.school_cohorts.first.update!(induction_programme_choice: :core_induction_programme)
      partnership
      partnership_notification_service.send_invite_sit_reminder_to_partnered_schools
    end

    it "doesn't email schools that have a SIT" do
      expect(SchoolMailer).to_not receive(:partnered_school_invite_sit_email)
      partnership
      create(:user, :induction_coordinator, schools: [school])
      partnership_notification_service.send_invite_sit_reminder_to_partnered_schools
    end
  end
end
