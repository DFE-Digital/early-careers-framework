# frozen_string_literal: true

RSpec.describe PartnershipNotificationService do
  subject(:partnership_notification_service) { described_class.new }
  let!(:lead_provider) { create :lead_provider }
  let!(:delivery_partner) { create :delivery_partner }
  let!(:cohort) { create(:cohort, start_year: 2021) }

  let(:school) { create(:school) }
  let(:partnership) do
    create(:partnership, {
      lead_provider: lead_provider,
      delivery_partner: delivery_partner,
      cohort: cohort,
      school: school,
    })
  end

  before do
    ProviderRelationship.create!(lead_provider: lead_provider, delivery_partner: delivery_partner, cohort: cohort)
  end

  describe "#notify" do
    context "when the school has no induction coordinator" do
      let(:contact_email) { Faker::Internet.email }
      let(:school) { create(:school, primary_contact_email: contact_email) }

      it "emails the school primary contact" do
        partnership_notification_service.notify(partnership)

        expect(SchoolMailer).to delay_email_delivery_of(:school_partnership_notification_email).with(
          partnership: partnership,
          reminder: false,
          access_token: an_object_having_attributes(
            class: SchoolAccessToken,
            school: school,
            permitted_actions: %i[nominate_tutor challenge_partnership],
          ),
        )
      end
    end

    context "when the school has an induction coordinator" do
      let(:contact_email) { Faker::Internet.email }
      let(:school) { create(:school) }
      let!(:coordinator) { create(:user, :induction_coordinator, schools: [school], email: contact_email) }

      it "emails the induction coordinator" do
        partnership_notification_service.notify(partnership)

        expect(SchoolMailer).to delay_email_delivery_of(:coordinator_partnership_notification_email).with(
          partnership: partnership,
          reminder: false,
          access_token: an_object_having_attributes(
            class: SchoolAccessToken,
            school: school,
            permitted_actions: %i[challenge_partnership],
          ),
        )
      end
    end
  end

  describe "#send_reminder" do
    context "when the school has no induction coordinator" do
      let(:contact_email) { Faker::Internet.email }
      let(:school) { create(:school, primary_contact_email: contact_email) }

      it "emails the school primary contact" do
        partnership_notification_service.send_reminder(partnership)

        expect(SchoolMailer).to delay_email_delivery_of(:school_partnership_notification_email).with(
          partnership: partnership,
          reminder: true,
          access_token: an_object_having_attributes(
            class: SchoolAccessToken,
            school: school,
            permitted_actions: %i[nominate_tutor challenge_partnership],
          ),
        )
      end
    end

    context "when the school has an induction coordinator" do
      let(:contact_email) { Faker::Internet.email }
      let(:school) { create(:school) }
      let!(:coordinator) { create(:user, :induction_coordinator, schools: [school], email: contact_email) }

      it "emails the induction coordinator" do
        partnership_notification_service.send_reminder(partnership)

        expect(SchoolMailer).to delay_email_delivery_of(:coordinator_partnership_notification_email).with(
          partnership: partnership,
          reminder: true,
          access_token: an_object_having_attributes(
            class: SchoolAccessToken,
            school: school,
            permitted_actions: %i[challenge_partnership],
          ),
        )
      end
    end
  end
end
