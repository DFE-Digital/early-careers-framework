# frozen_string_literal: true

class ProgrammeTypeMappings
  class << self
    def mappings_enabled?
      FeatureFlag.active?(:programme_type_changes_2025)
    end

    def withdrawl_reason(reason:)
      return reason unless mappings_enabled?

      case reason
      when "switched-to-school-led"
        "school-left-fip"
      else
        reason
      end
    end

    def training_programme(training_programme:)
      return training_programme unless mappings_enabled?

      case training_programme
      when "full_induction_programme", "school_funded_fip"
        "provider_led"
      else
        "school_led"
      end
    end
  end
end
