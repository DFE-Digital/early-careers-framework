# frozen_string_literal: true

RSpec.describe Admin::Participants::ChangeRelationship::WizardSteps::ChangeTrainingProgrammeStep, type: :model do
  let(:wizard) { instance_double(Admin::Participants::ChangeRelationship::ChangeRelationshipWizard) }
  subject(:step) { described_class.new(wizard:) }

  let(:default_partnership) { create(:seed_partnership, :valid) }
  let(:relationship) { create(:seed_partnership, :valid, relationship: true) }

  let(:expected_options) { ["create_new", relationship.id] }

  describe "validations" do
    before do
      allow(wizard).to receive(:school_partnerships).and_return([default_partnership, relationship])
      allow(wizard).to receive(:current_partnership).and_return(default_partnership)
      allow(wizard).to receive(:school_default_partnership).and_return(default_partnership)
    end
    it { is_expected.to validate_inclusion_of(:selected_partnership).in_array(expected_options) }
  end

  describe ".permitted_params" do
    it "returns permitted parameters" do
      expect(described_class.permitted_params).to eql %i[selected_partnership]
    end
  end

  describe "#expected" do
    let(:can_be_changed) { true }

    before do
      allow(wizard).to receive(:programme_can_be_changed?).and_return(can_be_changed)
    end

    context "when the programme can be changed" do
      it "returns true" do
        expect(step).to be_expected
      end
    end

    context "when the programme cannot be changed" do
      let(:can_be_changed) { false }

      it "returns false" do
        expect(step).not_to be_expected
      end
    end
  end

  describe "#next_step" do
    let(:new_partnership) { true }

    before do
      allow(wizard).to receive(:create_new_partnership?).and_return(new_partnership)
    end

    context "when the choice is to create a new partnership" do
      it "returns :choose_lead_provider" do
        expect(step.next_step).to eql :choose_lead_provider
      end

      context "when an existing partnership is chosen" do
        let(:new_partnership) { false }

        it "returns :cannot_change_programme" do
          expect(step.next_step).to eql :confirm_selected_partnership
        end
      end
    end
  end

  describe "#options" do
    before do
      allow(wizard).to receive(:school_partnerships).and_return([default_partnership, relationship])
      allow(wizard).to receive(:current_partnership).and_return(default_partnership)
      allow(wizard).to receive(:school_default_partnership).and_return(default_partnership)
    end

    it "returns the permitted options" do
      expect(step.options.map(&:id)).to match_array expected_options
    end
  end
end
