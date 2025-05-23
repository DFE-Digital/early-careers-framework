# frozen_string_literal: true

require "has_recordable_information"

module Oneoffs
  class MigrateDeclarationsBetweenStatements
    class StatementMismatchError < RuntimeError; end
    class PaidStatementMigrationError < RuntimeError; end

    include HasRecordableInformation

    def initialize(
      cohort:,
      from_statement_name:,
      to_statement_name:,
      from_statement_updates: {},
      to_statement_updates: {},
      restrict_to_lead_providers: nil,
      restrict_to_declaration_types: nil,
      restrict_to_declaration_states: nil,
      restrict_to_course_identifiers: nil,
      restrict_to_created_on_or_before: nil
    )
      @cohort = cohort
      @from_statement_name = from_statement_name
      @to_statement_name = to_statement_name
      @to_statement_updates = to_statement_updates
      @from_statement_updates = from_statement_updates
      @restrict_to_lead_providers = restrict_to_lead_providers
      @restrict_to_declaration_types = restrict_to_declaration_types
      @restrict_to_declaration_states = restrict_to_declaration_states
      @restrict_to_course_identifiers = restrict_to_course_identifiers
      @restrict_to_created_on_or_before = restrict_to_created_on_or_before
    end

    def migrate(dry_run: true)
      reset_recorded_info
      prevent_migrating_from_paid_statement!
      warn_unless_to_statements_are_future_dated
      ensure_statements_align!
      record_summary_info(dry_run)

      ActiveRecord::Base.transaction do
        migrate_declarations_between_statements!
        update_from_statement_attributes!
        update_to_statement_attributes!

        raise ActiveRecord::Rollback if dry_run
      end

      recorded_info
    end

  private

    attr_reader :cohort, :from_statement_name, :to_statement_name,
                :to_statement_updates, :from_statement_updates,
                :restrict_to_lead_providers, :restrict_to_declaration_types,
                :restrict_to_declaration_states, :restrict_to_course_identifiers,
                :restrict_to_created_on_or_before

    def update_from_statement_attributes!
      return if from_statement_updates.blank?

      from_statements_by_provider.each_value do |statement|
        statement.update!(from_statement_updates)
        record_info("Statement #{statement.name} for #{statement.lead_provider.name} updated with #{from_statement_updates}")
      end
    end

    def update_to_statement_attributes!
      return if to_statement_updates.blank?

      to_statements_by_provider.each_value do |statement|
        statement.update!(to_statement_updates)
        record_info("Statement #{statement.name} for #{statement.lead_provider.name} updated with #{to_statement_updates}")
      end
    end

    def migrate_declarations_between_statements!
      each_statements_by_provider do |provider, from_statement, to_statement|
        migrate_line_items!(provider, from_statement, to_statement)
      end
    end

    def migrate_line_items!(provider, from_statement, to_statement)
      statement_line_items = filter_statement_line_items(from_statement.statement_line_items)

      record_info("Migrating #{statement_line_items.size} declarations for #{provider.name}")
      statement_line_items.update!(statement_id: to_statement.id)

      make_eligible_declaration_payable_for_to_statement(to_statement, statement_line_items)
      make_payable_declaration_eligible_for_to_statement(to_statement, statement_line_items)
    end

    def each_statements_by_provider
      from_statements_by_provider.each do |provider, from_statement|
        to_statement = to_statements_by_provider[provider]
        yield(provider, from_statement, to_statement)
      end
    end

    def make_eligible_declaration_payable_for_to_statement(to_statement, statement_line_items)
      declarations = statement_line_items.map(&:participant_declaration).uniq
      eligible_declarations = declarations.select(&:eligible?)

      return unless to_statement.payable?
      return unless eligible_declarations.any?

      service = ParticipantDeclarations::MarkAsPayable.new(to_statement)
      action = service.class.to_s.underscore.humanize.split.last

      record_info("Marking #{eligible_declarations.size} eligible declarations as #{action} for #{to_statement.name} statement")

      eligible_declarations.each { |declaration| service.call(declaration) }
    end

    def make_payable_declaration_eligible_for_to_statement(to_statement, statement_line_items)
      declarations = statement_line_items.map(&:participant_declaration).uniq
      payable_declarations = declarations.select(&:payable?)

      return if to_statement.payable? || to_statement.paid?
      return unless payable_declarations.any?

      record_info("Marking #{payable_declarations.size} payable declarations back as eligible for #{to_statement.name} statement")

      payable_declarations.each { |declaration| DeclarationState.eligible!(declaration) }
      statement_line_items.select(&:payable?).map(&:eligible!)
    end

    def filter_statement_line_items(statement_line_items)
      scope = statement_line_items.includes(:participant_declaration)
      scope = scope.where(participant_declaration: { declaration_type: restrict_to_declaration_types }) if restrict_to_declaration_types
      scope = scope.where(participant_declaration: { state: restrict_to_declaration_states }) if restrict_to_declaration_states
      scope = scope.where(participant_declaration: { course_identifier: restrict_to_course_identifiers }) if restrict_to_course_identifiers
      scope = scope.where(participant_declaration: { created_at: ..restrict_to_created_on_or_before }) if restrict_to_created_on_or_before

      scope
    end

    def record_summary_info(dry_run)
      record_info("~~~ DRY RUN ~~~") if dry_run
      record_info("Migrating declarations from #{from_statement_name} to #{to_statement_name} for #{provider_count} providers")
    end

    def warn_unless_to_statements_are_future_dated
      record_info("Warning: to statements are not future dated") if to_statements_by_provider.values.any? { |statement| statement.deadline_date.past? }
    end

    def ensure_statements_align!
      statements_mismatch = from_statements_by_provider.keys.sort != to_statements_by_provider.keys.sort
      statements_empty = from_statements_by_provider.empty? && to_statements_by_provider.empty?

      raise StatementMismatchError, "There is a mismatch between to/from statements" if statements_mismatch
      raise StatementMismatchError, "No statements were found" if statements_empty
    end

    def prevent_migrating_from_paid_statement!
      raise PaidStatementMigrationError, "Cannot migrate from a paid statement" if from_statements_by_provider.values.any?(&:paid?)
    end

    def provider_count
      from_statements_by_provider.count
    end

    def from_statements_by_provider
      @from_statements_by_provider ||= statements_by_provider(from_statement_name)
    end

    def to_statements_by_provider
      @to_statements_by_provider ||= statements_by_provider(to_statement_name)
    end

    def statements_by_provider(statement_name)
      lead_provider = restrict_to_lead_providers || LeadProvider.all

      Finance::Statement::ECF
        .includes(:cohort, :participant_declarations, cpd_lead_provider: :lead_provider)
        .where(cohort:, name: statement_name, cpd_lead_provider: { lead_provider: })
        .group_by(&:lead_provider)
        .transform_values(&:first)
    end
  end
end
