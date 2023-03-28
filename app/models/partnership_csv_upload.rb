# frozen_string_literal: true

class PartnershipCsvUpload < ApplicationRecord
  has_paper_trail
  has_one_attached :csv
  belongs_to :lead_provider, optional: true
  belongs_to :delivery_partner, optional: true
  belongs_to :cohort

  validate :csv_validation

  MAX_FILE_SIZE = 2.megabytes

  def invalid_schools
    @invalid_schools ||= find_school_errors
  end

  def valid_schools
    invalid_urns = invalid_schools.map { |error| error[:urn] }
    valid_urns = urns - invalid_urns
    # We need to preserve order uploaded
    valid_schools = valid_urns.map { |urn| School.find_by(urn:).presence || School.find_by(urn: urn.sub!(/^0+/, "")) }
    Sentry.capture_message("Found nil schools in `valid_schools`") if valid_schools.any?(&:nil?)
    valid_schools.compact
  end

  def urns
    @urns ||= csv.open { |csv| csv.readlines.map(&:chomp) }
                 .map { |s| strip_bom(s) }
                 .uniq
  end

  # NOTE: this method is intended for short term use while we migrate the urn
  # lists from ActiveStorage to Postgres arrays
  def sync_uploaded_urns
    uploaded_urns = csv.download
      .force_encoding("UTF-8")
      .scrub
      .lines(chomp: true)
      .map { |urn| urn.chars.select { |c| c =~ /\w/ }.join }

    return if uploaded_urns.blank?

    update!(uploaded_urns:)
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
      school = School.includes(:partnerships).find_by(urn:)
      school = School.find_by(urn: urn.sub(/^0+/, "")) if school.blank?

      if school.blank?
        errors << { urn:, message: "URN is not valid", school_name: "", row_number: index + 1 }
      elsif school.cip_only?
        errors << { urn:, message: "School not eligible for funding", school_name: school.name, row_number: index + 1 }
      elsif !school.eligible?
        errors << { urn:, message: "School not eligible for inductions", school_name: school.name, row_number: index + 1 }
      elsif school.lead_provider(cohort.start_year) == lead_provider
        errors << { urn:, message: "Your school - already confirmed", school_name: school.name, row_number: index + 1 }
      elsif school.lead_provider(cohort.start_year).present? || has_previous_cohort_and_matching_lead_provider?(school)
        errors << { urn:, message: "Recruited by other provider", school_name: school.name, row_number: index + 1 }
      end
    end

    errors
  end

  def has_previous_cohort_and_matching_lead_provider?(school)
    previous_year_lead_provider = school.lead_provider(cohort.start_year - 1)

    return false if previous_year_lead_provider.blank?

    previous_year_lead_provider != lead_provider && school.school_cohorts.find_by(cohort:).blank?
  end

  def strip_bom(string)
    string.force_encoding("UTF-8").gsub(/\xEF\xBB\xBF/, "")
  end
end
