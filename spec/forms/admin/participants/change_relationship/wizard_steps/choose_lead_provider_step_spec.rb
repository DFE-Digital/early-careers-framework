# frozen_string_literal: true

RSpec.describe Admin::Participants::ChangeRelationship::WizardSteps::ChooseLeadProviderStep, type: :model do
  let(:wizard) { instance_double(Admin::Participants::ChangeRelationship::ChangeRelationshipWizard) }
  subject(:step) { described_class.new(wizard:) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:lead_provider_id) }
  end

  describe ".permitted_params" do
    it "returns permitted parameters" do
      expect(described_class.permitted_params).to eql %i[lead_provider_id]
    end
  end

  describe "#expected" do
    let(:new_partnership) { true }

    before do
      allow(wizard).to receive(:create_new_partnership?).and_return(new_partnership)
    end

    context "when creating a new partnership has been chosen" do
      it "returns true" do
        expect(step).to be_expected
      end
    end

    context "when selecting an existing partnership was chosen" do
      let(:new_partnership) { false }

      it "returns false" do
        expect(step).not_to be_expected
      end
    end
  end

  describe "#next_step" do
    it "returns :choose_delivery_partner" do
      expect(step.next_step).to eql :choose_delivery_partner
    end
  end

  describe "#options" do
    let(:providers) { create_list(:seed_lead_provider, 2, :valid) }

    before do
      allow(wizard).to receive(:available_providers_for_participant_cohort).and_return(providers)
    end

    it "returns the permitted options" do
      expect(step.options.map(&:id)).to match_array providers.map(&:id)
    end
  end
end
