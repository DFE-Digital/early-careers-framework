# frozen_string_literal: true

RSpec.describe Induction::CreateRelationship do
  describe "#call" do
    let(:school_cohort) { create :school_cohort }
    let(:lead_provider) { create(:lead_provider) }
    let(:delivery_partner) { create(:delivery_partner) }

    subject(:service) { described_class }

    it "adds a new Partnership record" do
      expect {
        service.call(school_cohort: school_cohort,
                     lead_provider: lead_provider,
                     delivery_partner: delivery_partner)
      }.to change { school_cohort.school.partnerships.count }.by 1
    end

    it "sets the relationship flag on the Partnership" do
      service.call(school_cohort: school_cohort,
                   lead_provider: lead_provider,
                   delivery_partner: delivery_partner)

      expect(school_cohort.school.partnerships.last).to be_relationship
    end
  end
end
