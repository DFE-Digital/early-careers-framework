# frozen_string_literal: true

module Admin
  module Schools
    class PartnershipComponent < ViewComponent::Base
      attr_accessor :partnership, :school, :school_cohort

      def initialize(partnership:, school:, school_cohort:)
        @partnership = partnership
        @school = school
        @school_cohort = school_cohort
      end

      def heading
        tag.h2(safe_join([cohort.start_year, "partnership"], " "))
      end

      def cip?
        induction_programme_choice == "core_induction_programme"
      end

      def fip?
        induction_programme_choice == "full_induction_programme"
      end

      def other?
        !cip? && !fip?
      end

      def training_programme
        {
          "core_induction_programme" => "Using DfE-accredited materials",
          "design_our_own"           => "Designing their own training",
          "full_induction_programme" => "Working with a DfE-funded provider",
          "no_early_career_teachers" => "No ECTs this year",
          "school_funded_fip"        => "School-funded full induction programme",
        }.fetch(induction_programme_choice, "Not using service")
      end

      def allow_change_programme?
        return true if cip? || other?

        school_cohort.lead_provider.nil?
      end

      def change_programme_href
        admin_school_change_programme_path(id: school_cohort.start_year, school_id: school.slug)
      end

      def materials
        school_cohort.default_induction_programme&.core_induction_programme&.name
      end

      def change_materials_href
        admin_school_change_training_materials_path(id: school_cohort.cohort.start_year, school_id: school_cohort.school.slug)
      end

      def appropriate_body_name
        school_cohort.appropriate_body&.name
      end

      def lead_provider_name
        partnership.lead_provider.name
      end

      def delivery_partner_name
        partnership.delivery_partner.name
      end

    private

      def induction_programme_choice
        school_cohort.induction_programme_choice
      end

      def visually_hidden(text)
        tag.span(text, class: "govuk-visually-hidden")
      end
    end
  end
end
