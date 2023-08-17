# frozen_string_literal: true

module Admin
  module Schools
    class RelationshipComponent < ViewComponent::Base
      attr_accessor :relationship, :school, :school_cohort

      def initialize(relationship:, school:, school_cohort:)
        @relationship = relationship
        @school = school
        @school_cohort = school_cohort
      end

      def challenge_href
        govuk_link_to("Challenge relationship", new_admin_school_partnership_challenge_partnership_path(school_cohort.school, relationship))
      end
    end
  end
end
