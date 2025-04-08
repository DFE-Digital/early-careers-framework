# frozen_string_literal: true

class ProgrammeTypeMappings
  class << self
    def mappings_enabled?
      FeatureFlag.active?(:programme_type_changes_2025)
    end

    def withdrawal_reason(reason:)
      return reason unless mappings_enabled?

      case reason
      when "school-left-fip"
        "switched-to-school-led"
      else
        reason
      end
    end

    def training_programme(training_programme:)
      return training_programme unless mappings_enabled?

      case training_programme
      when "full_induction_programme", "school_funded_fip"
        "provider_led"
      when "core_induction_programme", "design_our_own"
        "school_led"
      else
        training_programme
      end
    end

    def training_programme_friendly_name(training_programme, length: :long)
      translation_key = training_programme(training_programme:)
      I18n.t("training_programme.#{length}.#{translation_key}")
    end
  end
end
