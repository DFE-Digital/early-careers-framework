# frozen_string_literal: true

require "rails_helper"

RSpec.describe PartnershipRequest, type: :model do
  let(:lead_provider) { create(:lead_provider) }
  let(:delivery_partner) { create(:delivery_partner) }
  let(:school) { create(:school) }
  let(:cohort) { create(:cohort) }
  let(:partnership_request) do
    PartnershipRequest.create!(
      lead_provider: lead_provider,
      delivery_partner: delivery_partner,
      school: school,
      cohort: cohort,
    )
  end
  let!(:school_cohort) { create(:school_cohort, school: school, cohort: cohort, induction_programme_choice: "core_induction_programme") }

  it "enables paper trail" do
    is_expected.to be_versioned
  end

  describe "associations" do
    it { is_expected.to belong_to(:school) }
    it { is_expected.to belong_to(:lead_provider) }
    it { is_expected.to belong_to(:cohort) }
    it { is_expected.to belong_to(:delivery_partner) }
  end

  describe "create" do
    it "should create a partnership finalisation job" do
      freeze_time
      partnership_request

      expect(PartnershipFinalisationJob).to have_been_enqueued.with(partnership_request).at(2.weeks.from_now)
    end
  end

  describe "#finalize!" do
    it "creates a partnership with the correct attributes" do
      expect { partnership_request.finalise! }.to change { Partnership.count }.by(1)

      created_partnership = Partnership.order(:created_at).last
      expect(created_partnership.lead_provider).to eql lead_provider
      expect(created_partnership.delivery_partner).to eql delivery_partner
      expect(created_partnership.school).to eql school
      expect(created_partnership.cohort).to eql cohort
    end

    it "updates the school cohort to FIP" do
      partnership_request.finalise!
      expect(school_cohort.reload.induction_programme_choice).to eql "full_induction_programme"
    end

    it "should destroy the partnership request" do
      partnership_request.finalise!
      expect(partnership_request.destroyed?).to be true
    end

    it "associates any notification emails with the new partnership" do
      email = create(:partnership_notification_email, partnerable: partnership_request)
      partnership_request.finalise!

      created_partnership = Partnership.order(:created_at).last
      expect(created_partnership.partnership_notification_emails).to contain_exactly email
    end
  end

  describe "challenge!" do
    it "should create a challenged partnership" do
      freeze_time
      expect { partnership_request.challenge!("mistake") }.to change { Partnership.count }.by(1)

      created_partnership = Partnership.order(:created_at).last
      expect(created_partnership.lead_provider).to eql lead_provider
      expect(created_partnership.delivery_partner).to eql delivery_partner
      expect(created_partnership.school).to eql school
      expect(created_partnership.cohort).to eql cohort
      expect(created_partnership.challenge_reason).to eql "mistake"
      expect(created_partnership.challenged_at).to eql Time.zone.now
    end

    it "should destroy the partnership request" do
      partnership_request.challenge!("mistake")
      expect(partnership_request.destroyed?).to be true
    end

    it "should raise an error if called with a blank reason" do
      expect { partnership_request.challenge!("") }.to raise_error(ArgumentError)
      expect(partnership_request.destroyed?).to be false
    end

    it "associates any notification emails with the new partnership" do
      email = create(:partnership_notification_email, partnerable: partnership_request)
      partnership_request.challenge!("mistake")

      created_partnership = Partnership.order(:created_at).last
      expect(created_partnership.partnership_notification_emails).to contain_exactly email
    end
  end
end
