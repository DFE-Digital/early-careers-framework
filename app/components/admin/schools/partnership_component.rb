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

      def training_programme
        {
          "full_induction_programme" => "Working with a DfE-funded provider",
          "school_funded_fip"        => "School-funded full induction programme",
        }.fetch(induction_programme_choice)
      end

      def heading
        tag.h2(safe_join([cohort.start_year, "partnership"], " "))
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
