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

    describe ".training_programme_friendly_name" do
      subject { described_class.training_programme_friendly_name(training_programme, short:) }

      context("when short: false") do
        let(:short) { false }

        context "when mappings are enabled" do
          let(:mappings_enabled) { true }

          %i[full_induction_programme school_funded_fip].each do |induction_programme_type|
            context "when training_programme is '#{induction_programme_type}'" do
              let(:training_programme) { build(:induction_programme, induction_programme_type).training_programme }

              it { is_expected.to eq("Provider led") }
            end
          end

          %i[core_induction_programme design_our_own].each do |induction_programme_type|
            context "when training_programme is '#{induction_programme_type}'" do
              let(:training_programme) { build(:induction_programme, induction_programme_type).training_programme }

              it { is_expected.to eq("School led") }
            end
          end
        end

        context "when mappings are not enabled" do
          let(:mappings_enabled) { false }

          context "when training_programme is `full_induction_programme`" do
            let(:training_programme) { build(:induction_programme, :fip).training_programme }

            it { is_expected.to eq("Full induction programme") }
          end

          context "when training_programme is `core_induction_programme`" do
            let(:training_programme) { build(:induction_programme, :cip).training_programme }

            it { is_expected.to eq("Core induction programme") }
          end

          context "when training_programme is `design_our_own`" do
            let(:training_programme) { build(:induction_programme, :design_our_own).training_programme }

            it { is_expected.to eq("Design our own") }
          end

          context "when training_programme is `school_funded_fip`" do
            let(:training_programme) { build(:induction_programme, :school_funded_fip).training_programme }

            it { is_expected.to eq("School funded full induction programme") }
          end
        end
      end

      context("when short: true") do
        let(:short) { true }

        context "when mappings are enabled" do
          let(:mappings_enabled) { true }

          %i[full_induction_programme school_funded_fip].each do |induction_programme_type|
            context "when training_programme is '#{induction_programme_type}'" do
              let(:training_programme) { build(:induction_programme, induction_programme_type).training_programme }

              it { is_expected.to eq("Provider led") }
            end
          end

          %i[core_induction_programme design_our_own].each do |induction_programme_type|
            context "when training_programme is '#{induction_programme_type}'" do
              let(:training_programme) { build(:induction_programme, induction_programme_type).training_programme }

              it { is_expected.to eq("School led") }
            end
          end
        end

        context "when mappings are not enabled" do
          let(:mappings_enabled) { false }

          context "when training_programme is `full_induction_programme`" do
            let(:training_programme) { build(:induction_programme, :fip).training_programme }

            it { is_expected.to eq("FIP") }
          end

          context "when training_programme is `core_induction_programme`" do
            let(:training_programme) { build(:induction_programme, :cip).training_programme }

            it { is_expected.to eq("CIP") }
          end

          context "when training_programme is `design_our_own`" do
            let(:training_programme) { build(:induction_programme, :design_our_own).training_programme }

            it { is_expected.to eq("Design our own") }
          end

          context "when training_programme is `school_funded_fip`" do
            let(:training_programme) { build(:induction_programme, :school_funded_fip).training_programme }

            it { is_expected.to eq("School funded FIP") }
          end
        end
      end
    end
  end
end
