# frozen_string_literal: true

module Support
  module InductionProgrammes
    module Cip
      class FindOrCreate < Support::BaseService
        class << self
          def call(school_urn:, cohort_year:, cip_name:)
            new(
              school_urn:,
              cohort_year:,
              cip_name:,
            ).call
          end
        end

        attr_reader :school_urn,
                    :cohort_year,
                    :cip_name
        attr_writer :logger # allow logging to be disabled for specs

        def initialize(school_urn:, cohort_year:, cip_name:)
          @school_urn = school_urn
          @cohort_year = cohort_year
          @cip_name = cip_name
        end

        def call
          induction_programme = nil
          ActiveRecord::Base.transaction do
            induction_programme = school_cohort.induction_programmes
                                               .core_induction_programme
                                               .find_or_create_by!(core_induction_programme: CoreInductionProgramme.find_by!(name: cip_name)) do
              log_message("Creating core induction programme")
            end

            log_message("School core induction programme")
            log_message({
              induction_programme_id: induction_programme.id,
              school: induction_programme.school_cohort.school.urn,
              cip_name: induction_programme.core_induction_programme.name,
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
