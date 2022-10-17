# frozen_string_literal: true

RSpec.describe Induction::CreateRelationship do
  describe "#call" do
    let(:school_cohort) { create :school_cohort }
    let(:lead_provider) { create(:lead_provider) }
    let(:delivery_partner) { create(:delivery_partner) }
    let(:treat_as_partnership) { false }

    subject(:service_call) { described_class.call(school_cohort:, lead_provider:, delivery_partner:, treat_as_partnership:) }

    it "adds a new Partnership record" do
      expect { service_call }.to change { school_cohort.school.partnerships.count }.by 1
    end

    it "sets the relationship flag on the Partnership" do
      service_call
      expect(school_cohort.school.partnerships.last).to be_relationship
    end

    it "doesn't have a challenge window in the Partnership" do
      service_call
      expect(school_cohort.school.partnerships.last).not_to be_in_challenge_window
    end

    context "when treat_as_partnership is true" do
      let(:treat_as_partnership) { true }

      it "does not set the relationship flag" do
        service_call
        expect(school_cohort.school.partnerships.last).not_to be_relationship
      end

      it "doesn't have a challenge window in the Partnership" do
        service_call
        expect(school_cohort.school.partnerships.last).to be_in_challenge_window
      end
    end
  end
end
