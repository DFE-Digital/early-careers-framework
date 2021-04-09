# frozen_string_literal: true

require "rails_helper"

RSpec.describe InviteSchools do
  subject(:invite_schools) { described_class.new }
  let(:primary_contact_email) { Faker::Internet.email }
  let(:secondary_contact_email) { Faker::Internet.email }

  let(:school) do
    create(
      :school,
      primary_contact_email: primary_contact_email,
      secondary_contact_email: secondary_contact_email,
    )
  end

  describe "#run" do
    let(:nomination_email) { school.nomination_emails.last }

    it "creates a record for the nomination email" do
      expect {
        invite_schools.run [school.urn]
      }.to change { school.nomination_emails.count }.by 1
    end

    it "creates a nomination email with the correct fields" do
      invite_schools.run [school.urn]
      expect(nomination_email.sent_to).to eq school.primary_contact_email
      expect(nomination_email.sent_at).to be_present
      expect(nomination_email.token).to be_present
    end

    it "sends the nomination email" do
      expect(SchoolMailer).to receive(:nomination_email).with(
        hash_including(
          reference: String,
          school_name: String,
          nomination_url: String,
          recipient: school.primary_contact_email,
        ),
      ).and_call_original

      invite_schools.run [school.urn]
    end

    context "when school primary contact email is null" do
      let(:primary_contact_email) { nil }

      it "sends the nomination email to the secondary contact" do
        expect(SchoolMailer).to receive(:nomination_email).with(
          hash_including(
            reference: String,
            school_name: String,
            nomination_url: String,
            recipient: school.secondary_contact_email,
          ),
        ).and_call_original

        invite_schools.run [school.urn]
      end
    end

    context "when there is an error creating the nomination email" do
      let(:primary_contact_email) { nil }
      let(:secondary_contact_email) { nil }
      let(:another_school) { create(:school) }

      it "skips to the next school_id" do
        invite_schools.run [school.urn, another_school.urn]
        expect(school.nomination_emails).to be_empty
        expect(another_school.nomination_emails).not_to be_empty
      end
    end
  end

  describe "#sent_email_recently?" do
    it "is false when the school has not been emailed" do
      expect(invite_schools.sent_email_recently?(school)).to eq false
    end

    context "when the school has been emailed more than 24 hours ago" do
      before do
        create(:nomination_email, school: school, sent_at: 25.hours.ago)
      end

      it "returns false" do
        expect(invite_schools.sent_email_recently?(school)).to eq false
      end
    end

    context "when the school has been emailed within the last 24 hours" do
      before do
        create(:nomination_email, school: school)
      end

      it "returns true" do
        expect(invite_schools.sent_email_recently?(school)).to eq true
      end
    end

    context "when the school has been emailed more than one" do
      before do
        create(:nomination_email, school: school, sent_at: 5.days.ago)
      end

      context "and have been emailed within the last 24 hours" do
        before do
          create(:nomination_email, school: school)
        end

        it "returns true" do
          expect(invite_schools.sent_email_recently?(school)).to eq true
        end
      end

      context "and the school has not been emailed within the last 24 hours" do
        before do
          create(:nomination_email, school: school, sent_at: 25.hours.ago)
        end

        it "returns false" do
          expect(invite_schools.sent_email_recently?(school)).to eq false
        end
      end
    end
  end
end
