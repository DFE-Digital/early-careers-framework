# frozen_string_literal: true

class PartnershipCsvUpload < ApplicationRecord
  has_one_attached :csv
  # does this need a delivery partner reference ?
  belongs_to :lead_provider, optional: true

  validate :csv_validation

  MAX_FILE_SIZE = 2.megabytes

private

  def csv_validation
    return unless csv.attached?

    if csv.content_type != "text/csv"
      errors.add(:base, "File must be a CSV")
    end

    if csv.byte_size > MAX_FILE_SIZE
      errors.add(:base, "File must be less than 2mb.")
    end
  end
end
