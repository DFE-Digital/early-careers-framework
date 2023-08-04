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
        expect(SchoolMailer).to receive(:with).with(
          partnership:,
          nominate_url: String,
          challenge_url: String,
          recipient: contact_email,
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
        expect(SchoolMailer).to receive(:with).with(
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
        expect(SchoolMailer).to receive(:with).with(
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
        expect(SchoolMailer).to receive(:with).with(
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
end
