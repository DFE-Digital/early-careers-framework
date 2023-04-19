# frozen_string_literal: true

class ParticipantDeclaration::ECF < ParticipantDeclaration
  has_many :statements, class_name: "Finance::Statement::ECF", through: :statement_line_items

  def ecf?
    true
  end

  def uplift_paid?
    course_identifier == "ecf-induction" &&
      declaration_type == "started" &&
      %w[paid awaiting_clawback clawed_back].include?(state) &&
      (sparsity_uplift || pupil_premium_uplift)
  end
end
