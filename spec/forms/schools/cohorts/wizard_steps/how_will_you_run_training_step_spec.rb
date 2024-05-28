# frozen_string_literal: true

RSpec.describe Schools::Cohorts::WizardSteps::HowWillYouRunTrainingStep, type: :model do
  let(:wizard) { instance_double(Schools::Cohorts::SetupWizard) }
  subject(:step) { described_class.new(wizard:) }

  let(:programme_choices) do
    {
      full_induction_programme: "Use a training provider, funded by the DfE",
      core_induction_programme: "Deliver your own programme using DfE-accredited materials",
      school_funded_fip: "Use a training provider funded by your school",
      design_our_own: "Design and deliver your own programme based on the early career framework (ECF)",
    }
  end

  describe "validations" do
    let(:cip_only_valid) { %w[core_induction_programme school_funded_fip design_our_own] }
    let(:non_cip_only_valid) { %w[full_induction_programme core_induction_programme design_our_own] }

    context "when the school is cip-only" do
      before do
        allow(wizard).to receive(:school).and_return(double(cip_only?: true))
      end

      it { is_expected.to validate_inclusion_of(:how_will_you_run_training).in_array(cip_only_valid).with_message("Select how you will run training") }
    end

    context "when the school is not cip-only" do
      before do
        allow(wizard).to receive(:school).and_return(double(cip_only?: false))
      end

      it { is_expected.to validate_inclusion_of(:how_will_you_run_training).in_array(non_cip_only_valid).with_message("Select how you will run training") }
    end

    context "when option not selected" do
      before do
        allow(wizard).to receive(:school).and_return(double(cip_only?: false))
      end

      it "has a descriptive error message" do
        expect(step).to be_invalid
        expect(step.errors.messages_for(:how_will_you_run_training)).to include("Select how you will run training")
      end
    end
  end

  describe ".permitted_params" do
    it "returns the permitted params for the step" do
      expect(described_class.permitted_params).to eql %i[how_will_you_run_training]
    end
  end

  describe "#expected?" do
    context "when ects are not expected" do
      before do
        allow(wizard).to receive(:expect_any_ects?).and_return(false)
      end

      it "returns false" do
        expect(step).not_to be_expected
      end
    end

    context "when ects are expected" do
      before do
        allow(wizard).to receive(:expect_any_ects?).and_return(true)
      end

      context "when the school was not previously fip" do
        before do
          allow(wizard).to receive(:previously_fip?).and_return(false)
        end

        it "returns true" do
          expect(step).to be_expected
        end
      end

      context "when the school is cip-only and not previously fip" do
        before do
          allow(wizard).to receive(:previously_fip?).and_return(true)
          allow(wizard).to receive(:cip_only_school?).and_return(true)
        end

        it "returns true" do
          expect(step).to be_expected
        end
      end

      context "when the school is not cip-only and previous_fip" do
        before do
          allow(wizard).to receive(:previously_fip?).and_return(true)
          allow(wizard).to receive(:cip_only_school?).and_return(false)
        end

        it "returns false" do
          expect(step).not_to be_expected
        end
      end
    end
  end

  describe "#choices" do
    context "when the school is cip-only" do
      let(:choices) do
        programme_choices.except(:full_induction_programme).map { |id, name| OpenStruct.new(id:, name:) }
      end

      before do
        allow(wizard).to receive(:school).and_return(instance_double(School, cip_only?: true))
      end

      it "returns all choices but full induction programme" do
        expect(step.choices).to eq(choices)
      end
    end

    context "when the school is not cip-only" do
      let(:choices) do
        programme_choices.except(:school_funded_fip).map { |id, name| OpenStruct.new(id:, name:) }
      end

      before do
        allow(wizard).to receive(:school).and_return(instance_double(School, cip_only?: false))
      end

      it "returns all choices but school funded fip" do
        expect(step.choices).to eq(choices)
      end
    end
  end

  describe "#next_step" do
    it "returns :programme_confirmation" do
      expect(step.next_step).to eq(:programme_confirmation)
    end
  end
end
