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
      primary_contact_email: primary_contact_email,
      secondary_contact_email: secondary_contact_email,
    )
  end

  describe "#run" do
    it "enqueues nomination email" do
      expect {
        invite_schools.run [school.urn]
        perform_enqueued_jobs
      }.to change { ActionMailer::Base.deliveries.count }.by 1

      email = ActionMailer::Base.deliveries.last
      expect(email.to).to eq [school.primary_contact_email]
    end

    context "when the school is cip only" do
      let(:school) { create(:school, :cip_only, primary_contact_email: primary_contact_email) }

      it "still sends the nomination email" do
        expect {
          invite_schools.run [school.urn]
          perform_enqueued_jobs
        }.to change { ActionMailer::Base.deliveries.count }.by 1

        email = ActionMailer::Base.deliveries.last
        expect(email.to).to eq [school.primary_contact_email]
      end
    end

    context "when school primary contact email is empty" do
      let(:primary_contact_email) { "" }

      it "sends the nomination email to the secondary contact" do
        expect {
          invite_schools.run [school.urn]
          perform_enqueued_jobs
        }.to change { ActionMailer::Base.deliveries.count }.by 1

        email = ActionMailer::Base.deliveries.last
        expect(email.to).to eq [school.secondary_contact_email]
      end
    end
  end

  describe "#reached_limit" do
    subject(:reached_limit) { invite_schools.reached_limit(school) }

    context "when the school has not been emailed yet" do
      it { is_expected.to be_nil }
    end

    context "when the school has been emailed more than 5 minutes ago" do
      before do
        SchoolMailer.nomination_email(
          recipient: Faker::Internet.email,
          school: school,
        ).deliver_now

        travel_to 6.minutes.from_now
      end

      it { is_expected.to be nil }
    end

    context "when the school has been emailed within the last 5 minutes" do
      before do
        SchoolMailer.nomination_email(
          recipient: Faker::Internet.email,
          school: school,
        ).deliver_now

        travel_to 3.minutes.from_now
      end

      it { is_expected.to eq(max: 1, within: 5.minutes) }
    end

    context "when the school has been emailed four times in the last 24 hours" do
      before do
        4.times do
          SchoolMailer.nomination_email(
            recipient: Faker::Internet.email,
            school: school,
          ).deliver_now

          travel_to 5.hours.from_now
        end
      end

      it { is_expected.to be nil }
    end

    context "when the school has been emailed five times in the last 24 hours" do
      before do
        5.times do
          SchoolMailer.nomination_email(
            recipient: Faker::Internet.email,
            school: school,
          ).deliver_now

          travel_to 3.hours.from_now
        end
      end

      it { is_expected.to eq(max: 5, within: 24.hours) }
    end
  end
end
