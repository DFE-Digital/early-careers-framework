# frozen_string_literal: true

module Admin::Performance::OverviewHelper
  PROGRAMME_LABELS = {
    core_induction_programme: "Delivering their training using DfE materials",
    full_induction_programme: "Using a training provider (full induction programme)",
  }.freeze

  PROGRAMME_LABELS_2025 = {
    core_induction_programme: "Delivering school-led training",
    full_induction_programme: "Using provider-led training",
  }.freeze

  def programme_label_for(programme_type)
    programme_labels[programme_type.to_sym]
  end

  def programme_labels
    if FeatureFlag.active?(:programme_type_changes_2025)
      PROGRAMME_LABELS_2025
    else
      PROGRAMME_LABELS
    end
  end
end
