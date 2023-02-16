# frozen_string_literal: true

class ParticipantDeclaration::NPQ < ParticipantDeclaration
  belongs_to :participant_profile, class_name: "ParticipantProfile::NPQ"

  has_one :npq_application, through: :participant_profile

  has_many :statements, class_name: "Finance::Statement::NPQ", through: :statement_line_items

  has_many :outcomes, class_name: "ParticipantOutcome::NPQ", foreign_key: "participant_declaration_id"

  scope :for_course, ->(course_identifier) { where(course_identifier:) }
  scope :eligible_for_lead_provider_and_course, lambda { |cpd_lead_provider, course_identifier|
    for_lead_provider(cpd_lead_provider)
    .for_course(course_identifier)
    .eligible
  }
  scope :payable_for_lead_provider_and_course, lambda { |cpd_lead_provider, course_identifier|
    for_lead_provider(cpd_lead_provider)
    .for_course(course_identifier)
    .payable
  }
  scope :eligible_or_payable_for_lead_provider_and_course, lambda { |cpd_lead_provider, course_identifier|
    eligible_for_lead_provider_and_course(cpd_lead_provider, course_identifier)
      .or(payable_for_lead_provider_and_course(cpd_lead_provider, course_identifier))
      .unique_id
  }
  scope :submitted_for_lead_provider_and_course, lambda { |cpd_lead_provider, course_identifier|
    for_lead_provider(cpd_lead_provider)
    .for_course(course_identifier)
    .unique_id
    .submitted
  }
  scope :neither_paid_nor_voided_lead_provider_and_course, lambda { |cpd_lead_provider, course_identifier|
    for_lead_provider(cpd_lead_provider)
    .for_course(course_identifier)
    .where.not(state: states.values_at("paid", "voided"))
  }
  scope :valid_to_have_outcome_for_lead_provider_and_course, lambda { |cpd_lead_provider, course_identifier|
    for_declaration("completed")
    .for_lead_provider(cpd_lead_provider)
    .for_course(course_identifier)
    .where.not(state: states.values_at("voided", "awaiting_clawback", "clawed_back"))
    .order(created_at: :desc)
  }

  def self.with_outcomes_not_sent_to_qualified_teachers_api
    where(id: ParticipantOutcome::NPQ.not_sent_to_qualified_teachers_api.select(:participant_declaration_id))
  end

  def npq?
    true
  end
end
