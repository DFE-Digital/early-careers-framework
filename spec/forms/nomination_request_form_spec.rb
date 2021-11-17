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
    let(:invite_schools) { instance_spy InviteSchools }

    before do
      allow(InviteSchools).to receive(:new).and_return invite_schools
      allow(invite_schools).to receive(:reached_limit).with(school).and_return reached_limit
    end

    context "when nomination email limits for given school has not been breached yet" do
      let(:reached_limit) { nil }

      it "calls InviteSchools with the correct school" do
        nomination_request_form.save!

        expect(invite_schools).to have_received(:run).with([school.urn])
      end
    end

    context "when nomination email limits for given school has been breached" do
      let(:reached_limit) { { max: 100, within: 1.second } }

      it "raises TooManyEmailsError" do
        expect { nomination_request_form.save! }.to raise_error TooManyEmailsError

        expect(invite_schools).not_to have_received(:run)
      end
    end
  end
end
