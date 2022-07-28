# frozen_string_literal: true

class ParticipantDeclaration::ECF < ParticipantDeclaration
  has_many :statements, class_name: "Finance::Statement::ECF", through: :statement_line_items

  validate :validate_backdated_declaration_before_induction_record_end_date

  def validate_backdated_declaration_before_induction_record_end_date
    return if participant_profile.nil?

    previous_induction_record = participant_profile.relevant_induction_record(lead_provider: cpd_lead_provider.lead_provider)

    return if previous_induction_record.nil?
    return if previous_induction_record.end_date.nil?
    return if participant_profile.current_induction_record == previous_induction_record

    if previous_induction_record.end_date < declaration_date
      errors.add(:base, I18n.t("declaration_must_be_before_end_date"))
    end
  end
end
