# frozen_string_literal: true

require "has_recordable_information"

module Oneoffs
  class BackfillDeclarationCohort
    class UnexpectedDeclarationTypeError < RuntimeError; end

    include HasRecordableInformation

    BATCH_SIZE = 10_000

    def perform_change(dry_run: true)
      reset_recorded_info

      record_info("~~~ DRY RUN ~~~") if dry_run

      record_info("Backfilling #{participant_declarations_without_cohort.count} declarations with a cohort")

      participant_declarations_without_cohort.find_in_batches(batch_size: BATCH_SIZE).with_index do |declarations, index|
        record_info("Progress: #{(index * BATCH_SIZE / total_declarations_without_cohort.to_f * 100).round(0)}%")

        backfill_batch(declarations:, dry_run:)
      end

      record_info("Backfill complete")

      recorded_info
    end

  private

    def total_declarations_without_cohort
      @total_declarations_without_cohort ||= participant_declarations_without_cohort.count
    end

    def participant_declarations_without_cohort
      @participant_declarations_without_cohort ||= ParticipantDeclaration
        .includes(
          :cpd_lead_provider,
          :user,
          statements: :cohort,
          statement_line_items: { statement: :cohort },
          participant_profile: {
            schedule: :cohort,
          },
        )
        .where(cohort: nil)
    end

    def backfill_batch(declarations:, dry_run:)
      declarations_by_cohort = declarations.each_with_object({}) do |declaration, hash|
        cohort = infer_cohort(declaration)

        if cohort
          hash[cohort.id] ||= []
          hash[cohort.id] << declaration.id
        else
          record_info("Cohort could not be inferred for declaration #{declaration.id}")
        end
      end

      ActiveRecord::Base.transaction do
        declarations_by_cohort.each do |cohort_id, declaration_ids|
          ParticipantDeclaration.where(id: declaration_ids).update_all(cohort_id:)
        end

        raise ActiveRecord::Rollback if dry_run
      end
    end

    def infer_cohort(declaration)
      statement_cohorts = declaration.statements.map(&:cohort).uniq

      if statement_cohorts.many?
        statement_cohorts = declaration.statement_line_items.order(created_at: :asc).map { |item| item.statement.cohort }.uniq
        record_info("Declaration #{declaration.id} has multiple statements with different cohorts - selecting the first one")
      end

      return statement_cohorts.first if statement_cohorts.any?

      if declaration.ecf? || declaration.npq?
        declaration.participant_profile.schedule.cohort
      else
        raise UnexpectedDeclarationTypeError, "Unexpected declaration type: #{declaration.class}"
      end
    end
  end
end
