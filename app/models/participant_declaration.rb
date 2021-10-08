# frozen_string_literal: true

class ParticipantDeclaration < ApplicationRecord
  has_one :profile_declaration
  has_one :participant_profile, through: :profile_declaration
  has_many :declaration_states
  belongs_to :cpd_lead_provider
  belongs_to :user

  enum state: {
    submitted: "submitted",
    eligible: "eligible",
    payable: "payable",
    paid: "paid",
    voided: "voided",
  }

  alias_attribute :current_state, :state
  delegate :fundable?, to: :participant_profile, allow_nil: true

  validates :course_identifier, :user, :cpd_lead_provider, :declaration_date, :declaration_type, presence: true

  # Helper scopes
  scope :for_lead_provider, ->(cpd_lead_provider) { where(cpd_lead_provider: cpd_lead_provider) }
  scope :for_declaration, ->(declaration_type) { where(declaration_type: declaration_type) }
  scope :for_profile, ->(profile) { joins(:profile_declaration).joins(:participant_profile).where(participant_profile: profile) }
  scope :started, -> { for_declaration("started").order(declaration_date: "desc").unique_id }
  scope :uplift, -> { joins(:profile_declaration).merge(ProfileDeclaration.uplift) }
  scope :ect, -> { joins(:profile_declaration).merge(ProfileDeclaration.ect_profiles) }
  scope :mentor, -> { joins(:profile_declaration).merge(ProfileDeclaration.mentor_profiles) }
  scope :npq, -> { joins(:profile_declaration).merge(ProfileDeclaration.npq_profiles) }

  scope :changeable, -> { where(state: %w[eligible submitted]) }
  scope :unique_id, -> { select(:user_id).distinct }

  # Time dependent Range scopes
  scope :declared_as_between, ->(start_date, end_date) { where(declaration_date: start_date..end_date) }
  scope :submitted_between, ->(start_date, end_date) { where(created_at: start_date..end_date) }

  # Declaration aggregation scopes
  scope :eligible_for_lead_provider, ->(lead_provider) { for_lead_provider(lead_provider).unique_id.eligible }
  scope :eligible_ects_for_lead_provider, ->(lead_provider) { eligible_for_lead_provider(lead_provider).ect }
  scope :eligible_mentors_for_lead_provider, ->(lead_provider) { eligible_for_lead_provider(lead_provider).mentor }
  scope :eligible_npqs_for_lead_provider, ->(lead_provider) { eligible_for_lead_provider(lead_provider).npq }
  scope :eligible_uplift_for_lead_provider, ->(lead_provider) { eligible_for_lead_provider(lead_provider).uplift }

  scope :payable_for_lead_provider, ->(lead_provider) { for_lead_provider(lead_provider).unique_id.payable }
  scope :payable_ects_for_lead_provider, ->(lead_provider) { payable_for_lead_provider(lead_provider).ect }
  scope :payable_mentors_for_lead_provider, ->(lead_provider) { payable_for_lead_provider(lead_provider).mentor }
  scope :payable_npqs_for_lead_provider, ->(lead_provider) { payable_for_lead_provider(lead_provider).npq }
  scope :payable_uplift_for_lead_provider, ->(lead_provider) { payable_for_lead_provider(lead_provider).uplift }

  def refresh_payability!
    reload
    fundable? ? make_eligible! : make_submitted!
  end

  def make_submitted!
    DeclarationState.submitted!(self) if eligible?
  end

  def make_voided!
    DeclarationState.voided!(self) unless voided?
  end

  def make_eligible
    DeclarationState.eligible!(self)
  end

  def make_eligible!
    make_eligible if submitted?
  end

  def make_payable
    DeclarationState.payable!(self)
  end

  def make_payable!
    make_payable if eligible?
  end

  def make_paid
    DeclarationState.pay!(self)
  end

  def make_paid!
    make_paid if payable?
  end

  def changeable?
    %w[submitted eligible].include?(current_state)
  end
end
