# frozen_string_literal: true

class ParticipantDeclaration::NPQ < ParticipantDeclaration
  include RecordDeclarations::NPQ

  scope :for_course, ->(course_identifier) { where(course_identifier: course_identifier) }
  scope :for_lead_provider_and_course, ->(cpd_lead_provider, course_identifier) { for_lead_provider(cpd_lead_provider).for_course(course_identifier) }
  scope :eligible_and_payable_for_lead_provider_and_course, ->(cpd_lead_provider, course_identifier) { for_lead_provider(cpd_lead_provider).for_course(course_identifier).unique_id.eligible }
  scope :submitted_for_lead_provider_and_course, ->(cpd_lead_provider, course_identifier) { for_lead_provider(cpd_lead_provider).for_course(course_identifier).unique_id.submitted }
end
