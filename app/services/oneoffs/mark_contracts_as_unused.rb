# frozen_string_literal: true

require "has_recordable_information"

module Oneoffs
  class MarkContractsAsUnused
    include HasRecordableInformation

    DUPLICATE_ATTRIBUTES = %w[lead_provider_id cohort_id version].freeze
    EQUALITY_CHECK_IGNORE = {
      call_off_contract: %w[id raw created_at updated_at],
      participant_bands: %w[id call_off_contract_id created_at updated_at],
      mentor_call_off_contract: %w[id raw created_at updated_at],
    }.freeze

    def perform_change(dry_run: true)
      reset_recorded_info

      record_info("~~~ DRY RUN ~~~") if dry_run

      ActiveRecord::Base.transaction do
        mark_contracts_as_unused!(orphan_contracts, "no associated finance statement")
        mark_contracts_as_unused!(confirmed_duplicate_contracts, "duplicates")
        record_divergent_duplicate_info

        mark_mentor_contracts_as_unused!(orphan_mentor_contracts, "no associated finance statement")
        mark_mentor_contracts_as_unused!(confirmed_duplicate_mentor_contracts, "duplicates")
        record_mentor_divergent_duplicate_info

        raise ActiveRecord::Rollback if dry_run
      end

      recorded_info
    end

  private

    def mark_contracts_as_unused!(call_off_contracts, reason)
      record_info("Marking #{call_off_contracts.size} contracts as unused (#{reason})")

      call_off_contracts.each do |call_off_contract|
        call_off_contract.update!(version: "#{CallOffContract::UNUSED_VERSION_PREFIX}#{call_off_contract.version}")
      end
    end

    def orphan_contracts
      @orphan_contracts ||= call_off_contracts
        .joins(:lead_provider)
        .joins("LEFT JOIN statements ON
          statements.cpd_lead_provider_id = lead_providers.cpd_lead_provider_id
          AND statements.cohort_id = call_off_contracts.cohort_id
          AND statements.contract_version = call_off_contracts.version")
        .where(statements: { id: nil })
    end

    def confirmed_duplicate_contracts
      @confirmed_duplicate_contracts ||= potential_duplicate_contracts.flat_map do |original, duplicates|
        duplicates.select { |dup| call_off_contract_equal?(original, dup) }
      end
    end

    def divergent_duplicate_contracts
      @divergent_duplicate_contracts ||= potential_duplicate_contracts.values.flatten - confirmed_duplicate_contracts
    end

    def record_divergent_duplicate_info
      divergent_duplicate_contracts.each do |divergent_duplicate|
        original = potential_duplicate_contracts.find { |_, duplicates| duplicates.include?(divergent_duplicate) }.first
        record_info("Skipping duplicate (#{divergent_duplicate.id}) due to attributes differing with original (#{original.id})")
      end
    end

    def potential_duplicate_contracts
      @potential_duplicate_contracts ||= duplicated_contract_attributes.each_with_object({}) do |duplicate_condition, hash|
        duplicates = call_off_contracts.where(duplicate_condition).order(:created_at).to_a
        original = duplicates.shift
        hash[original] = duplicates
      end
    end

    def call_off_contract_equal?(original, duplicate)
      contracts_equal = attributes_equal?(original, duplicate, :call_off_contract)

      original_bands = original.participant_bands.min_nulls_first
      duplicate_bands = duplicate.participant_bands.min_nulls_first
      bands_equal = original_bands.zip(duplicate_bands).all? do |original_band, duplicate_band|
        attributes_equal?(original_band, duplicate_band, :participant_bands)
      end

      contracts_equal && bands_equal
    end

    def duplicated_contract_attributes
      @duplicated_contract_attributes ||= call_off_contracts
        .group(*DUPLICATE_ATTRIBUTES)
        .having("COUNT(*) > 1")
        .pluck(*DUPLICATE_ATTRIBUTES)
        .map { |values| DUPLICATE_ATTRIBUTES.zip(values).to_h.symbolize_keys }
    end

    def call_off_contracts
      @call_off_contracts ||= CallOffContract.not_flagged_as_unused
    end

    def mark_mentor_contracts_as_unused!(contracts, reason)
      record_info("Marking #{contracts.size} mentor contracts as unused (#{reason})")

      contracts.each do |contract|
        contract.update!(version: "#{MentorCallOffContract::UNUSED_VERSION_PREFIX}#{contract.version}")
      end
    end

    def orphan_mentor_contracts
      @orphan_mentor_contracts ||= mentor_call_off_contracts
        .joins(:lead_provider)
        .joins("LEFT JOIN statements ON
          statements.cpd_lead_provider_id = lead_providers.cpd_lead_provider_id
          AND statements.cohort_id = mentor_call_off_contracts.cohort_id
          AND statements.mentor_contract_version = mentor_call_off_contracts.version")
        .where(statements: { id: nil })
    end

    def confirmed_duplicate_mentor_contracts
      @confirmed_duplicate_mentor_contracts ||= potential_duplicate_mentor_contracts.flat_map do |original, duplicates|
        duplicates.select { |dup| mentor_call_off_contract_equal?(original, dup) }
      end
    end

    def divergent_duplicate_mentor_contracts
      @divergent_duplicate_mentor_contracts ||= potential_duplicate_mentor_contracts.values.flatten - confirmed_duplicate_mentor_contracts
    end

    def record_mentor_divergent_duplicate_info
      divergent_duplicate_mentor_contracts.each do |divergent_duplicate|
        original = potential_duplicate_mentor_contracts.find { |_, duplicates| duplicates.include?(divergent_duplicate) }.first
        record_info("Skipping mentor duplicate (#{divergent_duplicate.id}) due to attributes differing with original (#{original.id})")
      end
    end

    def potential_duplicate_mentor_contracts
      @potential_duplicate_mentor_contracts ||= duplicated_mentor_contract_attributes.each_with_object({}) do |duplicate_condition, hash|
        duplicates = mentor_call_off_contracts.where(duplicate_condition).order(:created_at).to_a
        original = duplicates.shift
        hash[original] = duplicates
      end
    end

    def mentor_call_off_contract_equal?(original, duplicate)
      attributes_equal?(original, duplicate, :mentor_call_off_contract)
    end

    def duplicated_mentor_contract_attributes
      @duplicated_mentor_contract_attributes ||= mentor_call_off_contracts
        .group(*DUPLICATE_ATTRIBUTES)
        .having("COUNT(*) > 1")
        .pluck(*DUPLICATE_ATTRIBUTES)
        .map { |values| DUPLICATE_ATTRIBUTES.zip(values).to_h.symbolize_keys }
    end

    def mentor_call_off_contracts
      @mentor_call_off_contracts ||= MentorCallOffContract.not_flagged_as_unused
    end

    def attributes_equal?(original, duplicate, ignore_key)
      original_attributes = original.attributes.except(*EQUALITY_CHECK_IGNORE[ignore_key])
      duplicate_attributes = duplicate.attributes.except(*EQUALITY_CHECK_IGNORE[ignore_key])

      original_attributes == duplicate_attributes
    end
  end
end
