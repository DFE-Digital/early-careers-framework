# frozen_string_literal: true

class ParticipantDeclaration < ApplicationRecord
  has_one :profile_declaration
  has_one :participant_profile, through: :profile_declaration
  has_many :declaration_states
  has_one :current_state, -> { order(created_at: :desc).limit(1) }, class_name: "DeclarationState"
  belongs_to :cpd_lead_provider
  belongs_to :user

  delegate :submitted?, :eligible?,:payable?, :voided?, :paid?, to: :current_state, allow_nil: false
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

  scope :submitted, -> { joins(:current_state).merge(DeclarationState.submitted) }
  scope :eligible, -> { joins(:current_state).merge(DeclarationState.eligible) }
  scope :payable, -> { joins(:current_state).where(DeclarationState.payable) }
  scope :paid, -> { joins(:current_state).where(DeclarationState.paid) }
  scope :voided, -> { joins(:current_state).where(DeclarationState.voided) }
  scope :changeable, -> { joins(:current_state).where(DeclarationState.changable) }
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
    new_state = fundable? ? "eligible" : "submitted"
    return if current_state.state == new_state

    DeclarationState.create!(participant_declaration: self, state: new_state) and reload if changeable?
  end

  def submit!
    DeclarationState.submit!(participant_declaration: self) and reload if eligible?
  end

  def void!
    DeclarationState.void!(participant_declaration: self) and reload unless voided?
  end

  def eligible
    DeclarationState.eligible!(participant_declaration: self)
  end

  def eligible!
    eligible and reload if submitted?
  end

  def payable
    DeclarationState.payable!(participant_declaration: self)
  end

  def payable!
    payable and reload if eligible?
  end

  def pay
    DeclarationState.pay!(participant_declaration: self)
  end

  def pay!
    pay and reload if payable?
  end

  def changeable?
    %w[submitted eligible].include?(current_state.state)
  end
end
