# frozen_string_literal: true

class PartnershipCsvUpload < ApplicationRecord
  has_paper_trail
  has_one_attached :csv
  belongs_to :lead_provider, optional: true
  belongs_to :delivery_partner, optional: true

  validate :csv_validation

  MAX_FILE_SIZE = 2.megabytes

  def invalid_schools
    @invalid_schools ||= find_school_errors
  end

  def valid_schools
    invalid_urns = invalid_schools.map { |error| error[:urn] }
    valid_urns = urns - invalid_urns
    valid_urns.map { |urn| School.find_by(urn: urn) } # We need to preserve order uploaded
  end

  def urns
    @urns ||= csv.open { |csv| csv.readlines.map(&:chomp) }
  end

private

  def csv_validation
    return unless csv.attached?

    if csv.filename.extension.downcase != "csv"
      errors.add(:base, "File must be a CSV")
    end

    if csv.byte_size > MAX_FILE_SIZE
      errors.add(:base, "File must be less than 2mb.")
    end
  end

  def find_school_errors
    errors = []

    urns.each_with_index do |urn, index|
      school = School.includes(:partnerships).find_by(urn: urn)
      school = School.find_by(urn: urn.sub!(/^[0]+/, "")) if school.blank?

      if school.blank?
        errors << { urn: urn, message: "URN is not valid", school_name: "", row_number: index + 1 }
      elsif school.cip_only?
        errors << { urn: urn, message: "School not eligible for funding", school_name: school.name, row_number: index + 1 }
      elsif !school.eligible?
        errors << { urn: urn, message: "School not eligible for inductions", school_name: school.name, row_number: index + 1 }
      elsif school.lead_provider(Cohort.current.start_year) == lead_provider
        errors << { urn: urn, message: "Your school - already confirmed", school_name: school.name, row_number: index + 1 }
      elsif school.lead_provider(Cohort.current.start_year).present?
        errors << { urn: urn, message: "Recruited by other provider", school_name: school.name, row_number: index + 1 }
      end
    end

    errors
  end
end
