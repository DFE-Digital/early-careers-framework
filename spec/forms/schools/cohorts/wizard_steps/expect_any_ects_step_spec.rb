# frozen_string_literal: true

RSpec.describe Schools::Cohorts::WizardSteps::ExpectAnyEctsStep, type: :model do
  let(:wizard) { instance_double(Schools::Cohorts::SetupWizard) }
  subject(:step) { described_class.new(wizard:) }

  describe "validations" do
    it { is_expected.to validate_inclusion_of(:expect_any_ects).in_array(%w[yes no]) }
  end

  describe ".permitted_params" do
    it "returns the permitted params for the step" do
      expect(described_class.permitted_params).to eql %i[expect_any_ects]
    end
  end

  describe "#expected?" do
    it "returns true" do
      expect(step.expected?).to be true
    end
  end

  describe "#expect_any_ects?" do
    context "when ects are expected" do
      it "returns true" do
        step.expect_any_ects = "yes"
        expect(step).to be_expect_any_ects
      end
    end

    context "when no ects are expected" do
      it "returns false" do
        step.expect_any_ects = nil
        expect(step).not_to be_expect_any_ects

        step.expect_any_ects = "no"
        expect(step).not_to be_expect_any_ects
      end
    end
  end

  describe "#complete?" do
    context "when ects are expected" do
      it "returns false" do
        step.expect_any_ects = "yes"
        expect(step.complete?).to be false
      end
    end

    context "when no ects are expected" do
      it "returns true" do
        step.expect_any_ects = nil
        expect(step.complete?).to be true

        step.expect_any_ects = "no"
        expect(step.complete?).to be true
      end
    end
  end

  describe "#next_step" do
    before do
      allow(wizard).to receive(:cip_only_school?).and_return(false)
    end

    context "when no ects are expected" do
      it "returns :no_expected_ects" do
        step.expect_any_ects = "no"
        expect(step.next_step).to eq :no_expected_ects
      end
    end

    context "when ects are expected" do
      before do
        step.expect_any_ects = "yes"
      end

      context "when cip only school" do
        before do
          allow(wizard).to receive(:cip_only_school?).and_return(true)
        end

        it "returns :how_will_you_run_training" do
          expect(step.next_step).to eq :how_will_you_run_training
        end
      end

      context "when not previously fip" do
        before do
          allow(wizard).to receive(:previously_fip?).and_return(false)
        end

        it "returns :how_will_you_run_training" do
          expect(step.next_step).to eq :how_will_you_run_training
        end
      end

      context "when previously fip" do
        before do
          allow(wizard).to receive(:previously_fip?).and_return(true)
        end

        context "when there is no partnership in previous cohort" do
          before do
            allow(wizard).to receive(:previous_partnership_exists?).and_return(false)
          end

          it "returns :what_changes" do
            expect(step.next_step).to eq :what_changes
          end
        end

        context "when there is a partnership in previous cohort" do
          before do
            allow(wizard).to receive(:previous_partnership_exists?).and_return(true)
          end

          context "when the LP and DP have a partnership in the new cohort" do
            before do
              allow(wizard).to receive(:provider_relationship_is_valid?).and_return(true)
            end

            it "returns :keep_providers" do
              expect(step.next_step).to eq :keep_providers
            end
          end

          context "when the LP and DP do not have a partnership in the new cohort" do
            before do
              allow(wizard).to receive(:provider_relationship_is_valid?).and_return(false)
            end

            it "returns :providers_relationship_has_changed" do
              expect(step.next_step).to eq :providers_relationship_has_changed
            end
          end
        end
      end
    end
  end
end
