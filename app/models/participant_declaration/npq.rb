# frozen_string_literal: true

class ParticipantDeclaration::NPQ < ParticipantDeclaration
  QUALIFICATION_TYPES = {
    "npq-leading-teaching" => "NPQLT",
    "npq-leading-behaviour-culture" => "NPQLBC",
    "npq-leading-teaching-development" => "NPQLTD",
    "npq-leading-literacy" => "NPQLL",
    "npq-senior-leadership" => "NPQSL",
    "npq-headship" => "NPQH",
    "npq-executive-leadership" => "NPQEL",
    "npq-early-years-leadership" => "NPQEYL",
  }.freeze

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

  def npq?
    true
  end

  def qualification_type
    QUALIFICATION_TYPES.fetch(course_identifier)
  rescue KeyError => e
    Rails.logger.warn("A NPQ Qualification types mapping is missing: #{e.message}")
    Sentry.capture_exception(e)

    nil
  end
end
