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

  describe "#reached_email_limit" do
    before do
      allow_any_instance_of(InviteSchools)
        .to receive(:reached_limit).with(school)
        .and_return service_limit
    end

    let(:service_limit) { double("service limit") }
    subject { nomination_request_form.reached_email_limit }

    it { is_expected.to be service_limit }
  end

  describe "#save!" do
    it "calls InviteSchools with the correct school" do
      expect_any_instance_of(InviteSchools).to receive(:perform).with([school.urn])

      nomination_request_form.save!
    end

    context "when the school has been emailed in the last 24 hours" do
      before do
        create(:nomination_email, school: school)
      end

      it "does not call run on InviteSchools" do
        expect_any_instance_of(InviteSchools).not_to receive(:perform)
      end

      it "raises TooManyEmailsError if the school has been emailed in the last 24 hours" do
        expect {
          nomination_request_form.save!
        }.to raise_error TooManyEmailsError
      end
    end
  end
end
