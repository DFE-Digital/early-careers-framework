# frozen_string_literal: true

require "rails_helper"

RSpec.describe LeadProviders::ReportSchoolsForm, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:delivery_partner_id).on(:delivery_partner).with_message("Choose a delivery partner") }
  end

  describe "#save!" do
    let(:school_ids) { Array.new(rand 5..10) { Random.uuid } }
    let(:cohort_id) { Random.uuid }
    let(:lead_provider_id) { Random.uuid }
    let(:delivery_partner_id) { Random.uuid }

    subject do
      described_class.new(
        school_ids: school_ids,
        cohort_id: cohort_id,
        lead_provider_id: lead_provider_id,
        delivery_partner_id: delivery_partner_id,
      )
    end

    before do
      allow(Partnerships::Report).to receive(:call)
    end


    it "reports partnership with all the given school ids" do
      subject.save!

      school_ids.each do |school_id|
        expect(Partnerships::Report).to have_received(:call).with(
          school_id: school_id,
          cohort_id: cohort_id,
          lead_provider_id: lead_provider_id,
          delivery_partner_id: delivery_partner_id,
        )
      end
    end
  end
end
