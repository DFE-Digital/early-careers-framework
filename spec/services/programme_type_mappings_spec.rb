# frozen_string_literal: true

RSpec.describe ProgrammeTypeMappings do
  describe "mappings_enabled?" do
    subject { described_class }

    context "when the programme_type_changes_2025 feature flag is enabled" do
      before { FeatureFlag.activate(:programme_type_changes_2025) }

      it { is_expected.to be_mappings_enabled }
    end

    context "when the programme_type_changes_2025 feature flag is disabled" do
      before { FeatureFlag.deactivate(:programme_type_changes_2025) }

      it { is_expected.not_to be_mappings_enabled }
    end
  end

  describe "mappings" do
    before { allow(described_class).to receive(:mappings_enabled?) { mappings_enabled } }

    describe ".withdrawal_reason" do
      subject { described_class.withdrawal_reason(reason:) }

      context "when mappings are enabled" do
        let(:mappings_enabled) { true }

        context "when reason is 'school-left-fip'" do
          let(:reason) { "school-left-fip" }

          it { is_expected.to eq("switched-to-school-led") }
        end

        context "when reason is not 'school-left-fip'" do
          let(:reason) { "other" }

          it { is_expected.to eq(reason) }
        end
      end

      context "when mappings are disabled" do
        let(:mappings_enabled) { false }

        context "when reason is 'school-left-fip'" do
          let(:reason) { "school-left-fip" }

          it { is_expected.to eq(reason) }
        end
      end
    end

    describe ".training_programme" do
      subject { described_class.training_programme(training_programme:) }

      context "when mappings are enabled" do
        let(:mappings_enabled) { true }

        %w[full_induction_programme school_funded_fip].each do |param|
          context "when training_programme is '#{param}'" do
            let(:training_programme) { param }

            it { is_expected.to eq("provider_led") }
          end
        end

        %w[core_induction_programme design_our_own].each do |param|
          context "when training_programme is '#{param}'" do
            let(:training_programme) { param }

            it { is_expected.to eq("school_led") }
          end
        end

        %w[no_early_career_teachers not_yet_known].each do |param|
          context "when training_programme is '#{param}'" do
            let(:training_programme) { param }

            it { is_expected.to eq(training_programme) }
          end
        end
      end

      context "when mappings are disabled" do
        let(:mappings_enabled) { false }

        %w[
          full_induction_programme
          school_funded_fip
          core_induction_programme
          design_our_own
          no_early_career_teachers
          not_yet_known
        ].each do |param|
          context "when training_programme is '#{param}'" do
            let(:training_programme) { param }

            it { is_expected.to eq(training_programme) }
          end
        end
      end
    end
  end
end
