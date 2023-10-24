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

      def training_programme
        {
          "core_induction_programme" => "Using DfE-accredited materials",
          "design_our_own"           => "Designing their own training",
          "full_induction_programme" => "Working with a DfE-funded provider",
          "no_early_career_teachers" => "No ECTs this year",
          "school_funded_fip"        => "School-funded full induction programme",
        }.fetch(induction_programme_choice, "Not using service")
      end

      def materials
        school_cohort.default_induction_programme&.core_induction_programme&.name
      end

      def change_materials_href
        admin_school_change_training_materials_path(id: school_cohort.cohort.start_year, school_id: school_cohort.school.slug)
      end

      def heading
        "#{cohort.start_year} programme"
      end

      def empty?
        school_cohort.blank?
      end

      def build_partnerships
        partnerships&.each do |partnership|
          with_partnership_component(school:, school_cohort:, partnership:, training_programme:)
        end
      end

      def build_relationships
        relationships&.each do |relationship|
          with_relationship_component(school:, school_cohort:, relationship:, superuser:)
        end
      end

      def has_partnerships_or_relationships?
        partnerships.present? || relationships.present?
      end

      def cip?
        school_cohort.core_induction_programme?
      end

      def fip?
        school_cohort.full_induction_programme?
      end

      def other?
        !cip? && !fip?
      end

      def allow_change_programme?
        cip? || other? || school_cohort.lead_provider.nil?
      end

      def change_programme_href
        admin_school_change_programme_path(id: school_cohort.start_year, school_id: school.slug)
      end

      def change_appropriate_body_href
        admin_school_change_appropriate_body_path(school.id, school_cohort.id)
      end

    private

      def induction_programme_choice
        school_cohort&.induction_programme_choice
      end
    end
  end
end
