# frozen_string_literal: true

require "rails_helper"

RSpec.describe PartnershipNotificationService do
  subject(:partnership_notification_service) { described_class.new }
  before do
    @lead_provider = create(:lead_provider)
    @delivery_partner = create(:delivery_partner)
    @cohort = create(:cohort, start_year: 2021)
    ProviderRelationship.create!(lead_provider: @lead_provider, delivery_partner: @delivery_partner, cohort: @cohort)
  end

  let(:school) { create(:school) }
  let(:partnership) do
    create(:partnership,
           lead_provider: @lead_provider,
           delivery_partner: @delivery_partner,
           cohort: @cohort,
           school: school)
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
            lead_provider_name: @lead_provider.name,
            delivery_partner_name: @delivery_partner.name,
            cohort: String,
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
      before do
        create(:user, :induction_coordinator, schools: [school], email: contact_email)
      end

      before(:all) do
        RSpec::Mocks.configuration.verify_partial_doubles = false
      end

      after(:all) do
        RSpec::Mocks.configuration.verify_partial_doubles = true
      end

      it "emails the induction coordinator" do
        expect(SchoolMailer).to receive(:coordinator_partnership_notification_email).with(
          hash_including(
            lead_provider_name: @lead_provider.name,
            delivery_partner_name: @delivery_partner.name,
            cohort: String,
            start_url: String,
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
            lead_provider_name: @lead_provider.name,
            delivery_partner_name: @delivery_partner.name,
            cohort: String,
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
      before do
        create(:user, :induction_coordinator, schools: [school], email: contact_email)
      end

      before(:all) do
        RSpec::Mocks.configuration.verify_partial_doubles = false
      end

      after(:all) do
        RSpec::Mocks.configuration.verify_partial_doubles = true
      end

      it "emails the induction coordinator" do
        expect(SchoolMailer).to receive(:coordinator_partnership_notification_email).with(
          hash_including(
            lead_provider_name: @lead_provider.name,
            delivery_partner_name: @delivery_partner.name,
            cohort: String,
            start_url: String,
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
  end
end
