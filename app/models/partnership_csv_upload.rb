# frozen_string_literal: true

class PartnershipCsvUpload < ApplicationRecord
  has_one_attached :csv
  belongs_to :lead_provider, optional: true

  validate :csv_validation

private

  def csv_validation
    return unless csv.attached?

    if csv.content_type != "text/csv"
      errors[:base] << "File must be a CSV"
    end

    if csv.byte_size > 2.megabytes
      errors[:base] << "File must be less than 2mb."
    end
  end
end
