# frozen_string_literal: true

require "rails_helper"

RSpec.describe NominationRequestForm, type: :model do
  let(:local_authority) { create(:local_authority) }
  let(:school) { create(:school, school_local_authorities: [SchoolLocalAuthority.new(local_authority: local_authority, start_year: 2019)]) }
  subject(:nomination_request_form) { described_class.new(school_id: school.id, local_authority_id: local_authority.id) }

  describe "validations" do
    it {
      is_expected.to validate_presence_of(:local_authority_id)
                       .with_message("The details you entered do not match any schools")
                       .on(%i[local_authority save])
    }
    it {
      is_expected.to validate_presence_of(:school_id)
                       .with_message("The details you entered do not match any schools")
                       .on(%i[school save])
    }
  end

  describe "#email_limit_reached?" do
    context "when the school has been emailed in the last 24 hours" do
      before do
        create(:nomination_email, school: school)
      end

      it "returns true" do
        expect(nomination_request_form.email_limit_reached?).to eq true
      end
    end

    context "when the school has not been emailed" do
      it "returns false" do
        expect(nomination_request_form.email_limit_reached?).to eq false
      end
    end

    context "when the school has been emailed more than 24 hours ago" do
      before do
        create(:nomination_email, school: school, sent_at: 25.hours.ago)
      end

      it "returns false" do
        expect(nomination_request_form.email_limit_reached?).to eq false
      end
    end
  end

  describe "#save!" do
    it "calls InviteSchools with the correct school" do
      expect_any_instance_of(InviteSchools).to receive(:run).with([school.urn])

      nomination_request_form.save!
    end

    context "when the school has been emailed in the last 24 hours" do
      before do
        create(:nomination_email, school: school)
      end

      it "does not call run on InviteSchools" do
        expect_any_instance_of(InviteSchools).not_to receive(:run)
      end

      it "raises TooManyEmailsError if the school has been emailed in the last 24 hours" do
        expect {
          nomination_request_form.save!
        }.to raise_error TooManyEmailsError
      end
    end
  end
end
