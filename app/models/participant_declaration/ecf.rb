# frozen_string_literal: true

class ParticipantDeclaration::ECF < ParticipantDeclaration
  self.inheritance_column = :temp_type

  has_many :statements, class_name: "Finance::Statement::ECF", through: :statement_line_items

  validate :validate_against_profile_type

  def ecf?
    true
  end

  def uplift_paid?
    course_identifier == "ecf-induction" &&
      declaration_type == "started" &&
      %w[paid awaiting_clawback clawed_back].include?(state) &&
      (sparsity_uplift || pupil_premium_uplift)
  end

  def validate_against_profile_type
    return unless participant_profile
    return if participant_profile.type.demodulize == temp_type.demodulize

    errors.add(:type, I18n.t(:declaration_type_must_match_profile_type))
  end

  def temp_type=(value)
    super
    self.type = value
  end
end
