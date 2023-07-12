# frozen_string_literal: true

RSpec.describe Admin::Participants::ChangeRelationship::WizardSteps::ChooseDeliveryPartnerStep, type: :model do
  let(:wizard) { instance_double(Admin::Participants::ChangeRelationship::ChangeRelationshipWizard) }
  subject(:step) { described_class.new(wizard:) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:delivery_partner_id) }
  end

  describe ".permitted_params" do
    it "returns permitted parameters" do
      expect(described_class.permitted_params).to eql %i[delivery_partner_id]
    end
  end

  describe "#expected" do
    let(:new_partnership) { true }
    let(:selected_provider) { create(:seed_lead_provider, :valid) }

    before do
      allow(wizard).to receive(:create_new_partnership?).and_return(new_partnership)
      allow(wizard).to receive(:selected_lead_provider).and_return(selected_provider)
    end

    context "when creating a new partnership and a lead provider has been chosen" do
      it "returns true" do
        expect(step).to be_expected
      end
    end

    context "when not creating a new partnership" do
      let(:new_partnership) { false }

      it "returns false" do
        expect(step).not_to be_expected
      end
    end

    context "when a lead provider has not yet been chosen" do
      let(:selected_provider) { nil }

      it "returns false" do
        expect(step).not_to be_expected
      end
    end
  end

  describe "#next_step" do
    let(:partnership_exists) { false }

    before do
      allow(step).to receive(:partnership_exists?).and_return(partnership_exists)
    end

    it "returns :confirm_new_relationship" do
      expect(step.next_step).to eql :confirm_new_relationship
    end

    context "when there is already a matching partnership for the selected LP/DP at the school for the cohort" do
      let(:partnership_exists) { true }

      it "returns :relationship_already_exists" do
        expect(step.next_step).to eql :relationship_already_exists
      end
    end
  end

  describe "#options" do
    let(:partners) { create_list(:seed_delivery_partner, 2, :valid) }

    before do
      allow(wizard).to receive(:available_delivery_partners_for_provider).and_return(partners)
    end

    it "returns the permitted options" do
      expect(step.options.map(&:id)).to match_array partners.map(&:id)
    end
  end
end
