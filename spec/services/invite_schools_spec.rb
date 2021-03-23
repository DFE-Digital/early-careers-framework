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
        invite_schools.run [school.id]
      }.to change { school.nomination_emails.count }.by 1
    end

    it "creates a nomination email with the correct fields" do
      invite_schools.run [school.id]
      expect(nomination_email.sent_to).to eq school.primary_contact_email
      expect(nomination_email.sent_at).to be_present
      expect(nomination_email.token).to be_present
    end

    it "sends the nomination email" do
      expect(SchoolMailer).to receive(:nomination_email).with(
        school.primary_contact_email, String, String
      ).and_call_original

      invite_schools.run [school.id]
    end

    context "when school primary contact email is null" do
      let(:primary_contact_email) { nil }

      it "sends the nomination email to the secondary contact" do
        expect(SchoolMailer).to receive(:nomination_email).with(
          school.secondary_contact_email, String, String
        ).and_call_original

        invite_schools.run [school.id]
      end
    end

    context "when there is an error creating the nomination email" do
      let(:primary_contact_email) { nil }
      let(:secondary_contact_email) { nil }
      let(:another_school) { create(:school) }

      it "skips to the next school_id" do
        invite_schools.run [school.id, another_school.id]
        expect(school.nomination_emails).to be_empty
        expect(another_school.nomination_emails).not_to be_empty
      end
    end
  end
end
