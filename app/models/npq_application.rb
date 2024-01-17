# frozen_string_literal: true

class NPQApplication < ApplicationRecord
  VALID_FUNDING_ELIGIBILITY_STATUS_CODES = %w[
    funded
    no_institution
    ineligible_establishment_type
    ineligible_institution_type
    previously_funded
    not_new_headteacher_requesting_ehco
    school_outside_catchment
    early_years_outside_catchment
    not_on_early_years_register
    early_years_invalid_npq
    marked_funded_by_policy
    marked_ineligible_by_policy
  ].freeze

  has_paper_trail only: %i[eligible_for_funding funding_eligiblity_status_code user_id npq_lead_provider_id npq_course_id created_at updated_at lead_provider_approval_status]

  self.ignored_columns = %w[user_id]

  has_one :school, class_name: "School", foreign_key: :urn, primary_key: :school_urn
  has_one :profile, class_name: "ParticipantProfile::NPQ", foreign_key: :id, touch: true
  belongs_to :participant_identity
  belongs_to :npq_lead_provider
  belongs_to :npq_course
  belongs_to :cohort, optional: true
  belongs_to :eligible_for_funding_updated_by, class_name: "User", optional: true

  alias_method :course, :npq_course

  after_commit :push_enrollment_to_big_query

  UK_CATCHMENT_AREA = %w[jersey_guernsey_isle_of_man england northern_ireland scotland wales].freeze

  enum headteacher_status: {
    no: "no",
    yes_when_course_starts: "yes_when_course_starts",
    yes_in_first_two_years: "yes_in_first_two_years",
    yes_over_two_years: "yes_over_two_years",
    yes_in_first_five_years: "yes_in_first_five_years",
    yes_over_five_years: "yes_over_five_years",
  }

  enum funding_choice: {
    school: "school",
    trust: "trust",
    self: "self",
    another: "another",
    employer: "employer",
  }

  enum lead_provider_approval_status: {
    pending: "pending",
    accepted: "accepted",
    rejected: "rejected",
  }

  scope :with_targeted_delivery_funding_eligibility, -> { where(targeted_delivery_funding_eligibility: true) }
  scope :does_not_work_in_school, -> { where(works_in_school: false) }
  scope :does_not_work_in_childcare, -> { where(works_in_childcare: false) }
  scope :not_eligible_for_funding, -> { where(eligible_for_funding: false) }
  scope :edge_case_statuses, lambda {
                               where(funding_eligiblity_status_code: %w[re_register
                                                                        no_institution
                                                                        awaiting_more_information
                                                                        marked_ineligible_by_policy
                                                                        marked_funded_by_policy])
                             }
  scope :created_at_range, ->(start_date, end_date) { where(created_at: start_date..end_date) }

  validates :eligible_for_funding_before_type_cast, inclusion: { in: [true, false, "true", "false"] }
  validate  :validate_funding_eligiblity_status_code_change, on: :admin

  delegate :start_year, to: :cohort, prefix: true, allow_nil: true

  delegate :user, to: :participant_identity
  delegate :id, :full_name, :email, to: :user, prefix: true

  delegate :id, :name, to: :npq_course, prefix: true
  delegate :id, :name, to: :npq_lead_provider, prefix: true
  alias_method :ecf_id, :id

  self.filter_attributes += [:teacher_reference_number]

  # this builds upon #eligible_for_funding
  # eligible_for_funding is solely based on what NPQ app knows
  # eg school, course etc
  # here we need to account for previous enrollments too
  def eligible_for_dfe_funding
    if previously_funded?
      false
    else
      eligible_for_funding
    end
  end

  def ineligible_for_funding_reason
    if previously_funded?
      return "previously-funded"
    end

    unless eligible_for_funding
      "establishment-ineligible"
    end
  end

  def in_uk_catchment_area?
    UK_CATCHMENT_AREA.include?(teacher_catchment)
  end

  def self.participant_declaration_finder(participant_identity_id)
    ParticipantDeclaration::NPQ.find_by_participant_profile_id(ParticipantProfile.find_by_participant_identity_id(participant_identity_id)&.id)
  end

  def declared_as_billable?
    profile.present? && profile.participant_declarations.billable.count.positive?
  end

  def has_submitted_declaration?
    profile.present? && profile.participant_declarations.where(state: "submitted").present?
  end

  def change_logs
    v1 = versions.where_attribute_changes("eligible_for_funding")
    v2 = versions.where_attribute_changes("funding_eligiblity_status_code")

    (v1 + v2)
      .uniq
      .sort { |a, b| b.created_at <=> a.created_at }
  end

  def save_and_dedupe_participant
    result = save
    NPQ::DedupeParticipant.new(npq_application: self, trn: teacher_reference_number).call if result
    result
  end

private

  def previously_funded?
    # This is an optimization used by the v3 NPQApplicationsQuery in order
    # to speed up the bulk-retrieval of NPQ applications.
    return transient_previously_funded if respond_to?(:transient_previously_funded)

    @previously_funded ||= participant_identity
      .npq_applications
      .where.not(id:)
      .where(npq_course: npq_course.rebranded_alternative_courses)
      .where(eligible_for_funding: true)
      .accepted
      .exists?
  end

  def push_enrollment_to_big_query
    if (saved_changes.keys & %w[cohort_id id lead_provider_approval_status]).present?
      NPQ::StreamBigQueryEnrollmentJob.perform_later(npq_application_id: id)
    end
  end

  def validate_funding_eligiblity_status_code_change
    if declared_as_billable? && eligible_for_funding == false
      errors.add(:base, :billable_declaration_exists)
    end
  end
end
