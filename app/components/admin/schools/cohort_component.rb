# frozen_string_literal: true

module Admin
  module Schools
    class CohortComponent < ViewComponent::Base
      renders_many :partnership_components, Admin::Schools::PartnershipComponent
      renders_many :relationship_components, Admin::Schools::RelationshipComponent

      attr_reader :school, :cohort, :school_cohort, :relationships, :partnerships, :superuser

      def initialize(school:, cohort:, school_cohort:, partnerships_and_relationships: [], superuser: false)
        @school = school
        @school_cohort = school_cohort
        @cohort = cohort
        @superuser = superuser

        @relationships, @partnerships = *partnerships_and_relationships&.compact&.partition(&:relationship?)
        build_partnerships
        build_relationships
      end

      def heading
        "#{cohort.start_year} programme"
      end

      def empty?
        partnership_components.none? && relationship_components.none?
      end

      def build_partnerships
        partnerships&.each do |partnership|
          with_partnership_component(school:, school_cohort:, partnership:)
        end
      end

      def build_relationships
        relationships&.each do |relationship|
          with_relationship_component(school:, school_cohort:, relationship:, superuser:)
        end
      end
    end
  end
end
