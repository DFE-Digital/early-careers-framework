# frozen_string_literal: true

class MentorCallOffContract < ApplicationRecord
  belongs_to :lead_provider
  belongs_to :cohort

  def describe
    previous_contract = self.class
      .where(
        lead_provider:,
        cohort:,
      )
      .to_a
      .sort_by { |c| Finance::ECF::ContractVersion.new(c.version).numerical_value }
      .reject { |c| Finance::ECF::ContractVersion.new(c.version).numerical_value >= Finance::ECF::ContractVersion.new(version).numerical_value }
      .last

    attributes = self.attributes.except("id", "lead_provider_id", "cohort_id", "created_at", "updated_at", "version", "raw")

    if previous_contract
      attributes = attributes.reject { |k, v| previous_contract.attributes[k].presence == v.presence }
    end

    attributes.map { |key, value| "#{key.humanize}: #{value}" }
  end
end
