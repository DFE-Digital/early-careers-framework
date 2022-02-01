# frozen_string_literal: true

class ParticipantDeclaration < ApplicationRecord
  has_many :declaration_states
  has_many :participant_declaration_attempts, dependent: :destroy
  belongs_to :cpd_lead_provider
  belongs_to :user
  belongs_to :participant_profile
  belongs_to :superseded_by, class_name: "ParticipantDeclaration", optional: true
  belongs_to :statement, optional: true, polymorphic: true
  has_many :supersedes, class_name: "ParticipantDeclaration", foreign_key: :superseded_by_id, inverse_of: :superseded_by

  enum state: {
    submitted: "submitted",
    eligible: "eligible",
    payable: "payable",
    paid: "paid",
    voided: "voided",
    ineligible: "ineligible",
  }

  alias_attribute :current_state, :state
  delegate :fundable?, to: :participant_profile, allow_nil: true

  validates :course_identifier, :user, :cpd_lead_provider, :declaration_date, :declaration_type, presence: true

  # Helper scopes
  scope :for_lead_provider, ->(cpd_lead_provider) { where(cpd_lead_provider: cpd_lead_provider) }
  scope :for_declaration, ->(declaration_type) { where(declaration_type: declaration_type) }
  scope :for_profile, ->(profile) { where(participant_profile: profile) }
  scope :started, -> { for_declaration("started").order(declaration_date: "desc").unique_id }
  scope :retained_1, -> { for_declaration("retained-1").order(declaration_date: "desc").unique_id }

  scope :uplift, -> { where(participant_profile_id: ParticipantProfile.uplift.select(:id)) }

  scope :ect, -> { where(participant_profile_id: ParticipantProfile::ECT.select(:id)) }
  scope :mentor, -> { where(participant_profile_id: ParticipantProfile::Mentor.select(:id)) }
  scope :npq, -> { where(participant_profile_id: ParticipantProfile::NPQ.select(:id)) }

  scope :changeable, -> { where(state: %w[eligible submitted]) }
  scope :unique_id, -> { select(:user_id).distinct }

  # Time dependent Range scopes
  scope :declared_as_between, ->(start_date, end_date) { where(declaration_date: start_date..end_date) }
  scope :submitted_between, ->(start_date, end_date) { where(created_at: start_date..end_date) }

  # Declaration aggregation scopes
  scope :submitted_for_lead_provider, ->(lead_provider) { for_lead_provider(lead_provider).unique_id.submitted }

  # NOTE: Most of the following will need to be supplemented with the date qualifiers above to get the correct numbers
  # for payment breakdown periods when view is restricted to a milestone period.
  scope :not_eligible_for_lead_provider, ->(lead_provider) { submitted_for_lead_provider(lead_provider) }
  scope :eligible_for_lead_provider, ->(lead_provider) { for_lead_provider(lead_provider).unique_id.eligible }
  scope :eligible_ects_for_lead_provider, ->(lead_provider) { eligible_for_lead_provider(lead_provider).ect }
  scope :eligible_mentors_for_lead_provider, ->(lead_provider) { eligible_for_lead_provider(lead_provider).mentor }
  scope :eligible_npqs_for_lead_provider, ->(lead_provider) { eligible_for_lead_provider(lead_provider).npq }
  scope :eligible_uplift_for_lead_provider, ->(lead_provider) { eligible_for_lead_provider(lead_provider).uplift }

  scope :not_payable_for_lead_provider, ->(lead_provider) { submitted_for_lead_provider(lead_provider).or(eligible_for_lead_provider(lead_provider)) }
  scope :payable_for_lead_provider, ->(lead_provider) { for_lead_provider(lead_provider).unique_id.payable }
  scope :payable_ects_for_lead_provider, ->(lead_provider) { payable_for_lead_provider(lead_provider).ect }
  scope :payable_mentors_for_lead_provider, ->(lead_provider) { payable_for_lead_provider(lead_provider).mentor }
  scope :payable_npqs_for_lead_provider, ->(lead_provider) { payable_for_lead_provider(lead_provider).npq }
  scope :payable_uplift_for_lead_provider, ->(lead_provider) { payable_for_lead_provider(lead_provider).uplift }

  scope :not_paid_for_lead_provider, ->(lead_provider) { submitted_for_lead_provider(lead_provider).or(eligible_for_lead_provider(lead_provider)) }
  scope :paid_for_lead_provider, ->(lead_provider) { for_lead_provider(lead_provider).unique_id.paid }
  scope :paid_ects_for_lead_provider, ->(lead_provider) { paid_for_lead_provider(lead_provider).ect }
  scope :paid_mentors_for_lead_provider, ->(lead_provider) { paid_for_lead_provider(lead_provider).mentor }
  scope :paid_npqs_for_lead_provider, ->(lead_provider) { paid_for_lead_provider(lead_provider).npq }
  scope :paid_uplift_for_lead_provider, ->(lead_provider) { paid_for_lead_provider(lead_provider).uplift }

  # TODO: Voiding paid should trigger clawbacks, but currently OOS
  def voidable?
    !voided? && !payable? && !paid?
  end

  def make_submitted!
    DeclarationState.submitted!(self) if eligible?
  end

  def make_voided!
    DeclarationState.voided!(self) if voidable?
  end

  def make_eligible!
    DeclarationState.eligible!(self) if submitted?
  end

  def make_payable!
    DeclarationState.payable!(self) if eligible?
  end

  def make_paid!
    DeclarationState.paid!(self) if payable?
  end

  def make_ineligible!(reason: nil)
    DeclarationState.ineligible!(self, state_reason: reason) if submitted?
  end

  def changeable?
    %w[submitted eligible].include?(current_state)
  end

  def duplicate_declarations
    self.class.joins(participant_profile: :teacher_profile)
      .where(participant_profiles: { teacher_profiles: { trn: participant_profile.teacher_profile.trn } })
      .where.not(participant_profiles: { teacher_profiles: { trn: nil } })
      .where.not(user_id: user_id, id: id)
      .where.not(state: self.class.states[:voided])
      .where(
        declaration_type: declaration_type,
        course_identifier: course_identifier,
        superseded_by_id: nil,
      )
  end
end

require "participant_declaration/ecf"
require "participant_declaration/npq"
