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

    def training_programme_friendly_name(name, short: false)
      long_names = if mappings_enabled?
                     {
                       "full_induction_programme" => "Provider led",
                       "core_induction_programme" => "School led",
                       "design_our_own" => "School led",
                       "school_funded_fip" => "Provider led",
                     }
                   else
                     {
                       "full_induction_programme" => "Full induction programme",
                       "core_induction_programme" => "Core induction programme",
                       "design_our_own" => "Design our own",
                       "school_funded_fip" => "School funded full induction programme",
                     }
                   end

      short_names = if mappings_enabled?
                      {
                        "full_induction_programme" => "Provider led",
                        "core_induction_programme" => "School led",
                        "design_our_own" => "School led",
                        "school_funded_fip" => "Provider led",
                      }
                    else
                      {
                        "full_induction_programme" => "FIP",
                        "core_induction_programme" => "CIP",
                        "design_our_own" => "Design our own",
                        "school_funded_fip" => "School funded FIP",
                      }
                    end

      short ? short_names.fetch(name) : long_names.fetch(name)
    end
  end
end
