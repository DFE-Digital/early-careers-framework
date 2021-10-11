# frozen_string_literal: true

require "csv"

class NPQApplicationCsvSerializer
  attr_reader :scope

  def initialize(scope)
    @scope = scope
  end

  def call
    CSV.generate do |csv|
      csv << csv_headers

      scope.each do |record|
        csv << to_row(record)
      end
    end
  end

private

  def csv_headers
    %w[
      id
      participant_id
      full_name
      email
      email_validated
      teacher_reference_number
      teacher_reference_number_validated
      school_urn
      school_ukprn
      headteacher_status
      eligible_for_funding
      funding_choice
      course_identifier
      status
    ]
  end

  def to_row(record)
    [
      record.id,
      record.user_id,
      record.user.full_name,
      record.user.email,
      true,
      record.teacher_reference_number,
      record.teacher_reference_number_verified,
      record.school_urn,
      record.school_ukprn,
      record.headteacher_status,
      record.eligible_for_funding,
      record.funding_choice,
      record.npq_course.identifier,
      record.lead_provider_approval_status,
    ]
  end
end
