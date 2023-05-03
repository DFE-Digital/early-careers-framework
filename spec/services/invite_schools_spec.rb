# frozen_string_literal: true

require "rails_helper"

RSpec.describe InviteSchools do
  subject(:invite_schools) { described_class.new }
  let(:primary_contact_email) { Faker::Internet.email }
  let(:secondary_contact_email) { Faker::Internet.email }
  let!(:cohort) { create(:cohort, :current) }

  let(:school) do
    create(
      :school,
      primary_contact_email:,
      secondary_contact_email:,
    )
  end

  before(:all) do
    RSpec::Mocks.configuration.verify_partial_doubles = false
  end

  before(:each) do
    allow_any_instance_of(Mail::TestMailer).to receive_message_chain(:response, :id) { "notify_id" }
  end

  after(:all) do
    RSpec::Mocks.configuration.verify_partial_doubles = true
  end

  describe "#run" do
    let(:nomination_email) { school.nomination_emails.last }

    it "creates a record for the nomination email" do
      expect { invite_schools.perform [school.urn] }
        .to change { school.nomination_emails.count }.by 1
    end

    it "creates a nomination email with the correct fields" do
      invite_schools.perform [school.urn]
      expect(nomination_email.sent_to).to eq school.primary_contact_email
      expect(nomination_email.sent_at).to be_present
      expect(nomination_email.token).to be_present
    end

    it "sends the nomination email" do
      travel_to(Time.utc(2000, 1, 1)) do
        expect(SchoolMailer).to receive(:with).with(
          hash_including(
            recipient: school.primary_contact_email,
            school:,
            nomination_url: String,
            expiry_date: "22 January 2000",
          ),
        ).and_call_original

        invite_schools.perform [school.urn]
      end
    end

    it "sets the notify id on the nomination email record" do
      invite_schools.perform [school.urn]
      expect(nomination_email.notify_id).to eq "notify_id"
    end

    context "when the school is cip only" do
      let(:school) { create(:school, :cip_only, primary_contact_email:) }

      it "still sends the nomination email" do
        travel_to(Time.utc(2000, 1, 1)) do
          expect(SchoolMailer).to receive(:with).with(
            hash_including(
              school:,
              nomination_url: String,
              recipient: school.primary_contact_email,
              expiry_date: "22 January 2000",
            ),
          ).and_call_original

          invite_schools.perform [school.urn]
        end
      end
    end

    context "when school primary contact email is empty" do
      let(:primary_contact_email) { "" }

      it "sends the nomination email to the secondary contact" do
        expect(SchoolMailer).to receive(:with).with(
          hash_including(
            school:,
            nomination_url: String,
            recipient: school.secondary_contact_email,
          ),
        ).and_call_original

        invite_schools.perform [school.urn]
      end
    end

    context "when there is an error creating the nomination email" do
      let(:primary_contact_email) { nil }
      let(:secondary_contact_email) { nil }
      let(:another_school) { create(:school) }

      it "skips to the next school_id" do
        invite_schools.perform [school.urn, another_school.urn]
        expect(school.nomination_emails).to be_empty
        expect(another_school.nomination_emails).not_to be_empty
      end
    end
  end

  context "when the school already has an induction tutor assigned" do
    let(:school) { create(:school) }
    let(:user) { create(:user) }
    let!(:induction_coordinator) { create(:induction_coordinator_profile, schools: [school], user:) }

    it "sends the change tutor email" do
      expect(SchoolMailer).to receive(:school_requested_signin_link_from_gias_email).with(
        hash_including(
          school:,
          nomination_link: String,
        ),
      ).and_call_original

      invite_schools.perform [school.urn]
    end
  end

  describe "#reached_limit" do
    subject { invite_schools.reached_limit(school) }

    context "when the school has not been emailed yet" do
      it { is_expected.to be_nil }
    end

    context "when the school has been emailed more than 5 minutes ago" do
      before do
        create(:nomination_email, school:, sent_at: 6.minutes.ago)
      end

      it { is_expected.to be nil }
    end

    context "when the school has been emailed within the last 5 minutes" do
      before do
        create(:nomination_email, school:, sent_at: 4.minutes.ago)
      end

      it { is_expected.to eq(max: 1, within: 5.minutes) }
    end

    context "when the school has been emailed four times in the last 24 hours" do
      before do
        create_list(:nomination_email, 4, school:, sent_at: 22.hours.ago)
      end

      it { is_expected.to be nil }
    end

    context "when the school has been emailed five times in the last 24 hours" do
      before do
        create_list(:nomination_email, 4, school:, sent_at: 22.hours.ago)
        create(:nomination_email, school:, sent_at: 3.minutes.ago)
      end

      it { is_expected.to eq(max: 5, within: 24.hours) }
    end
  end
end
