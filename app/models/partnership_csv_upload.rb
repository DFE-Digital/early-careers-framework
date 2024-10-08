# frozen_string_literal: true

class PartnershipCsvUpload < ApplicationRecord
  has_paper_trail
  belongs_to :lead_provider, optional: true
  belongs_to :delivery_partner, optional: true
  belongs_to :cohort

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
    uploaded_urns.uniq
  end

private

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
      elsif school.lead_provider(cohort.start_year).present?
        errors << { urn:, message: "Recruited by other provider", school_name: school.name, row_number: index + 1 }
      elsif cohort_not_setup_and_previously_fip?(school)
        errors << { urn:, message: "School programme not yet confirmed", school_name: school.name, row_number: index + 1 }
      end
    end

    errors
  end

  def cohort_not_setup_and_previously_fip?(school)
    previous_year_lead_provider = school.lead_provider(cohort.start_year - 1)
    return false if previous_year_lead_provider.blank?

    school.school_cohorts.find_by(cohort:).blank?
  end
end
