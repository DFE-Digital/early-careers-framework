# frozen_string_literal: true

module Admin
  module Schools
    class PartnershipComponent < ViewComponent::Base
      attr_accessor :partnership, :school, :school_cohort, :training_programme

      def initialize(partnership:, school:, school_cohort:, training_programme:)
        @partnership = partnership
        @school = school
        @school_cohort = school_cohort
        @training_programme = training_programme
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

      def change_appropriate_body_href
        admin_school_change_appropriate_body_path(school.id, school_cohort.id)
      end

    private

      def visually_hidden(text)
        tag.span(text, class: "govuk-visually-hidden")
      end
    end
  end
end
