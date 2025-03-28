# frozen_string_literal: true

RSpec.describe Schools::Cohorts::WizardSteps::HowWillYouRunTrainingStep, type: :model do
  let(:wizard) { instance_double(Schools::Cohorts::SetupWizard) }
  subject(:step) { described_class.new(wizard:) }

  let(:programme_choices) do
    {
      full_induction_programme: "Use a training provider, funded by the DfE",
      core_induction_programme: "Deliver your own programme using DfE-accredited materials",
      school_funded_fip: "Use a training provider funded by your school",
      design_our_own: "Design and deliver your own programme based on the Early Career Framework (ECF)",
    }
  end

  describe "validations" do
    context "when programme type changes for 2025 are not active", with_feature_flags: { programme_type_changes_2025: "inactive" } do
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
    end

    context "when programme type changes for 2025 are active", with_feature_flags: { programme_type_changes_2025: "active" } do
      let(:cip_only_valid) { %w[core_induction_programme school_funded_fip] }
      let(:non_cip_only_valid) { %w[full_induction_programme core_induction_programme] }

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
    context "when programme type changes for 2025 are not active", with_feature_flags: { programme_type_changes_2025: "inactive" } do
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
    context "when programme type changes for 2025 are active", with_feature_flags: { programme_type_changes_2025: "active" } do
      let(:programme_choices) do
        {
          full_induction_programme: {
            name: "Provider-led",
            description: "Your school will work with providers who will deliver early career framework based training funded by the Department for Education.",
          },
          school_funded_fip: {
            name: "Provider-led",
            description: "Your school will fund providers who will deliver early career framework based training.",
          },
          core_induction_programme: {
            name: "School-led",
            description: "Your school will deliver training based on the early career framework.",
          },
        }
      end

      context "when the school is cip-only" do
        let(:choices) do
          programme_choices.except(:full_induction_programme).map do |k, v|
            OpenStruct.new(id: k, name: v[:name], description: v[:description])
          end
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
          programme_choices.except(:school_funded_fip).map do |k, v|
            OpenStruct.new(id: k, name: v[:name], description: v[:description])
          end
        end

        before do
          allow(wizard).to receive(:school).and_return(instance_double(School, cip_only?: false))
        end

        it "returns all choices but school funded fip" do
          expect(step.choices).to eq(choices)
        end
      end
    end
  end

  describe "#next_step" do
    it "returns :programme_confirmation" do
      expect(step.next_step).to eq(:programme_confirmation)
    end
  end
end
