# frozen_string_literal: true

module Schools
  module Cohorts
    class SetupWizard < BaseWizard
      include Success

      delegate :appropriate_body_id, :appropriate_body_type, :appropriate_body_appointed?,
               :appropriate_body_not_listed?, :expect_any_ects?, :how_will_you_run_training,
               :keep_providers?, :no_appropriate_body_appointed?, :no_expect_any_ects?, :no_keep_providers?,
               :what_changes, to: :data_store

      def abort_path
        show_path_for(step: default_step_name)
      end

      def change_path_for(step:)
        schools_cohort_setup_show_change_path(**path_options(step:))
      end

      def cip_only_school?
        school.cip_only?
      end

      def data_store_class
        FormData::CohortSetupStore
      end

      def delivery_partner_to_be_confirmed?
        what_changes == "change_delivery_partner"
      end

      def previous_cohort
        @previous_cohort ||= Cohort.active_registration_cohort.previous
      end

      def previous_delivery_partner
        @previous_delivery_partner ||= school.delivery_partner_for(previous_cohort.start_year)
      end

      def previous_lead_provider
        @previous_lead_provider ||= school.lead_provider(previous_cohort.start_year)
      end

      def previous_school_cohort
        @previous_school_cohort ||= school.school_cohorts.previous
      end

      def previously_fip?
        previous_school_cohort&.fip?
      end

      def previous_partnership_exists?
        previous_lead_provider && previous_delivery_partner
      end

      def provider_relationship_is_valid?
        return false unless previous_lead_provider && previous_delivery_partner

        ProviderRelationship.where(lead_provider: previous_lead_provider,
                                   delivery_partner: previous_delivery_partner,
                                   cohort:).exists?
      end

      def school_cohort
        @school_cohort ||= school.school_cohorts.find_or_initialize_by(cohort:)
      end

      def show_path_for(step:)
        schools_cohort_setup_show_path(**path_options(step:))
      end

      def appropriate_body_default_selection
        if school.school_type_code == 37
          AppropriateBody.find_by(name: "Educational Success Partners (ESP)")
        elsif school.school_type_code == 10 || school.school_type_code == 11
          AppropriateBody.find_by(name: "Independent Schools Teacher Induction Panel (IStip)")
        end
      end
    end
  end
end
