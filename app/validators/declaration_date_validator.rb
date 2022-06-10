# frozen_string_literal: true

class DeclarationDateValidator < ActiveModel::Validator
  RFC3339_DATE_REGEX = /\A\d{4}-\d{2}-\d{2}T(\d{2}):(\d{2}):(\d{2})([.,]\d+)?(Z|[+-](\d{2})(:?\d{2})?)?\z/i

  def validate(record)
    date_has_the_right_format(record)
    declaration_within_milestone(record)
    record_does_not_exists_with_different_declaration_date(record)
  end

private

  def date_has_the_right_format(record)
    return if record.declaration_date.blank?
    return if record.raw_declaration_date.match?(RFC3339_DATE_REGEX)

    record.errors.add(:declaration_date, I18n.t(:invalid_declaration_date))
  end

  def declaration_within_milestone(record)
    return unless record.milestone

    if record.declaration_date < record.milestone.start_date.beginning_of_day
      record.errors.add(:declaration_date, I18n.t(:declaration_before_milestone_start))
    end

    if record.milestone.milestone_date.present? && (record.milestone.milestone_date.end_of_day <= record.declaration_date)
      record.errors.add(:declaration_date, I18n.t(:declaration_after_milestone_cutoff))
    end
  end

  def record_does_not_exists_with_different_declaration_date(record)
    return unless record.participant_profile

    declaration = record
                    .participant_profile
                    .participant_declarations
                    .not_voided
                    .find_by(
                      user: record.participant_identity.user,
                      course_identifier: record.course_identifier,
                      declaration_type: record.declaration_type,
                    )

    return unless declaration.present? && \
      (similar_declaration_for_same_lead_provider?(declaration, record) || same_declaration_for_a_different_lead_provider?(declaration, record))

    record.errors.add(
      :declaration_date,
      I18n.t(
        :declaration_with_another_date_already_exists,
        declaration_date: declaration.declaration_date.rfc3339,
      ),
    )
  end

  def similar_declaration_for_same_lead_provider?(declaration, record)
    declaration.declaration_date != record.declaration_date && declaration.cpd_lead_provider == record.cpd_lead_provider
  end

  def same_declaration_for_a_different_lead_provider?(declaration, record)
    declaration.cpd_lead_provider != record.cpd_lead_provider
  end
end
