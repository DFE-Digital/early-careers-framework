# frozen_string_literal: true

class ParticipantDeclaration::ECF < ParticipantDeclaration
  has_many :statements, class_name: "Finance::Statement::ECF", through: :statement_line_items

  before_save :set_temp_type

  def ecf?
    true
  end

  def uplift_paid?
    course_identifier == "ecf-induction" &&
      declaration_type == "started" &&
      %w[paid awaiting_clawback clawed_back].include?(state) &&
      (sparsity_uplift || pupil_premium_uplift)
  end

  def set_temp_type
    return unless participant_profile
    return unless temp_type.nil?

    self.temp_type = participant_profile.type.sub("ParticipantProfile", "ParticipantDeclaration")
  end
end
