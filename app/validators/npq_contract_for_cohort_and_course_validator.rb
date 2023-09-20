# frozen_string_literal: true

class NPQContractForCohortAndCourseValidator < ActiveModel::Validator
  def validate(record)
    return if record.errors.any?
    return unless npq_contract_for_cohort_and_course_missing?(record)

    record.errors.add(:cohort, options[:message] || I18n.t(:missing_npq_contract_for_cohort_and_course))
  end

private

  def npq_contract_for_cohort_and_course_missing?(record)
    return unless npq_course?(record)

    npq_contract_for_cohort_and_course(record).empty?
  end

  def npq_contract_for_cohort_and_course(record)
    NPQContract.where(
      cohort: record.cohort,
      npq_lead_provider: record.cpd_lead_provider.npq_lead_provider,
      course_identifier: record.course_identifier,
    )
  end

  def npq_course?(record)
    ParticipantProfile::NPQ::COURSE_IDENTIFIERS.include?(record.course_identifier)
  end
end
