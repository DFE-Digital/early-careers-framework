# frozen_string_literal: true

module Support
  module InductionProgrammes
    module Fip
      class FindOrCreate < Support::BaseService
        class << self
          def call(school_urn:, cohort_year:, lead_provider_name:, delivery_partner_name:)
            new(
              school_urn:,
              cohort_year:,
              lead_provider_name:,
              delivery_partner_name:,
            ).call
          end
        end

        attr_reader :school_urn,
                    :cohort_year,
                    :lead_provider_name,
                    :delivery_partner_name
        attr_writer :logger # allow logging to be disabled for specs

        def initialize(school_urn:, cohort_year:, lead_provider_name:, delivery_partner_name:)
          @school_urn = school_urn
          @cohort_year = cohort_year
          @lead_provider_name = lead_provider_name
          @delivery_partner_name = delivery_partner_name
        end

        def call
          induction_programme = nil

          ActiveRecord::Base.transaction do
            partnership = school.partnerships.find_or_create_by!(
              cohort: school_cohort.cohort,
              lead_provider: LeadProvider.find_by!(name: lead_provider_name),
              delivery_partner: DeliveryPartner.find_by!(name: delivery_partner_name),
            ) do
              log_message("Creating partnership")
            end

            log_message("School partnership")
            log_message({
              partnership_id: partnership.id,
              school: partnership.school.urn,
              cohort: partnership.cohort.start_year,
              lead_provider: partnership.lead_provider.name,
              delivery_partner: partnership.delivery_partner.name,
            }.as_json)

            induction_programme = school_cohort.induction_programmes.find_or_create_by!(
              school_cohort:,
              partnership:,
              training_programme: "full_induction_programme",
            ) do
              log_message("Creating induction programme")
            end

            log_message("Induction programme")
            log_message({
              induction_programme_id: induction_programme.id,
              school_cohort: induction_programme.school_cohort.id,
              partnership: induction_programme.partnership.id,
              training_programme: induction_programme.training_programme,
            }.as_json)
          end

          induction_programme
        rescue StandardError => e
          log_error("Rolling back transaction")
          log_error(e.message)
          log_error(e.backtrace)
        end

        def dry_run
          ActiveRecord::Base.transaction do
            call

            log_message("Dry run complete")
            log_message("Rolling back changes")

            raise ActiveRecord::Rollback
          end
        end

      private

        def school
          @school ||= School.find_by(urn: school_urn)
        end

        def school_cohort
          @school_cohort ||= school.school_cohorts.joins(:cohort).find_by!(cohorts: { start_year: cohort_year })
        end
      end
    end
  end
end
