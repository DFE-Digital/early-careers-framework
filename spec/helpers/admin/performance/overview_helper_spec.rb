# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::Performance::OverviewHelper, type: :helper do
  describe "#programme_label_for" do
    context "when programme type changes for 2025 are inactive", with_feature_flags: { programme_type_changes_2025: "inactive" } do
      it "returns the original label for core induction programme" do
        expect(programme_label_for(:core_induction_programme)).to eq "Delivering their training using DfE materials"
      end

      it "returns the original label for full induction programme" do
        expect(programme_label_for(:full_induction_programme)).to eq "Using a training provider (full induction programme)"
      end
    end

    context "when programme type changes for 2025 are active", with_feature_flags: { programme_type_changes_2025: "active" } do
      it "returns the 2025 label for core induction programme" do
        expect(programme_label_for(:core_induction_programme)).to eq "Delivering school-led training"
      end

      it "returns the 2025 label for full induction programme" do
        expect(programme_label_for(:full_induction_programme)).to eq "Using provider-led training"
      end
    end
  end
end
