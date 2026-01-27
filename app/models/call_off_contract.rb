# frozen_string_literal: true

class CallOffContract < ApplicationRecord
  UNUSED_VERSION_PREFIX = "unused_"
  DEFAULT_REVISED_RECRUITMENT_TARGET_PERCENTAGE = 1.5

  belongs_to :lead_provider
  belongs_to :cohort

  has_many :participant_bands

  scope :not_flagged_as_unused, -> { where.not("version LIKE ?", "#{UNUSED_VERSION_PREFIX}%") }

  def total_contract_value
    participant_bands.map(&:contract_value).sum
  end

  def band_a
    bands.first
  end

  def bands
    participant_bands.min_nulls_first
  end

  def include_uplift_fees?
    !uplift_amount.nil?
  end

  def describe
    previous_contract = self.class
      .not_flagged_as_unused
      .where(
        lead_provider:,
        cohort:,
      )
      .to_a
      .sort_by { |c| Finance::ECF::ContractVersion.new(c.version).numerical_value }
      .reject { |c| Finance::ECF::ContractVersion.new(c.version).numerical_value >= Finance::ECF::ContractVersion.new(version).numerical_value }
      .last

    attributes = self.attributes.except("id", "lead_provider_id", "cohort_id", "created_at", "updated_at", "version", "raw", "revised_target")

    participant_bands.min_nulls_first.each.with_index do |band, index|
      letter = ("A".ord + index).chr
      attributes["band_#{letter}"] = "#{band.per_participant}, #{band.min}-#{band.max}, #{band.output_payment_percentage}%, #{band.service_fee_percentage}%"
    end

    if previous_contract
      previous_attributes = previous_contract.attributes.except("id", "lead_provider_id", "cohort_id", "created_at", "updated_at", "version", "raw", "revised_target")
      previous_contract.participant_bands.min_nulls_first.each.with_index do |band, index|
        letter = ("A".ord + index).chr
        previous_attributes["band_#{letter}"] = "#{band.per_participant}, #{band.min}-#{band.max}, #{band.output_payment_percentage}%, #{band.service_fee_percentage}%"
      end

      attributes = attributes.reject { |k, v| previous_attributes[k].presence == v.presence }
    end

    result = attributes.map do |key, value|
      if key == "monthly_service_fee" && value.nil?
        "#{key.humanize}: default"
      else
        "#{key.humanize}: #{value}"
      end
    end

    return ["No changes"] if result.empty?

    result
  end

  delegate :set_up_recruitment_basis, to: :band_a
end
