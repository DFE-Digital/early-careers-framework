# frozen_string_literal: true

class ParticipantDeclaration::NPQ < ParticipantDeclaration
  include RecordDeclarations::NPQ

  belongs_to :participant_profile, class_name: "ParticipantProfile::NPQ"

  has_one :npq_application, through: :participant_profile

  has_many :statements, class_name: "Finance::Statement::NPQ", through: :statement_line_items

  scope :for_course, ->(course_identifier) { where(course_identifier: course_identifier) }
  scope :eligible_for_lead_provider_and_course, ->(cpd_lead_provider, course_identifier) { for_lead_provider(cpd_lead_provider).for_course(course_identifier).eligible }
  scope :payable_for_lead_provider_and_course, ->(cpd_lead_provider, course_identifier) { for_lead_provider(cpd_lead_provider).for_course(course_identifier).payable }
  scope :eligible_or_payable_for_lead_provider_and_course, lambda { |cpd_lead_provider, course_identifier|
    eligible_for_lead_provider_and_course(cpd_lead_provider, course_identifier)
      .or(payable_for_lead_provider_and_course(cpd_lead_provider, course_identifier))
      .unique_id
  }
  scope :submitted_for_lead_provider_and_course, ->(cpd_lead_provider, course_identifier) { for_lead_provider(cpd_lead_provider).for_course(course_identifier).unique_id.submitted }
  scope :neither_paid_nor_voided_lead_provider_and_course, ->(cpd_lead_provider, course_identifier) { for_lead_provider(cpd_lead_provider).for_course(course_identifier).where.not(state: states.values_at("paid", "voided")) }
end
