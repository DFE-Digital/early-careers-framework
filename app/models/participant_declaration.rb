# frozen_string_literal: true

class ParticipantDeclaration < ApplicationRecord
  has_one :profile_declaration
  has_one :participant_profile, through: :profile_declaration
  has_many :declaration_states
  has_one :current_state, -> { order(created_at: :desc).limit(1) }, class_name: "DeclarationState"
  belongs_to :cpd_lead_provider
  belongs_to :user

  delegate :submitted?, :payable?, :voided?, :paid?, to: :current_state, allow_nil: false
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
  scope :submitted, -> { joins(:current_state).where(current_state: { state: "submitted" }) }
  scope :payable, -> { joins(:current_state).where(current_state: { state: "payable" }) }
  scope :paid, -> { joins(:current_state).where(current_state: { state: "paid" }) }
  scope :voided, -> { joins(:current_state).where(current_state: { state: "voided" }) }
  scope :changeable, -> { joins(:current_state).where(current_state: { state: %w[submitted payable] }) }
  scope :unique_id, -> { select(:user_id).distinct }

  # Time dependent Range scopes
  scope :declared_as_between, ->(start_date, end_date) { where(declaration_date: start_date..end_date) }
  scope :submitted_between, ->(start_date, end_date) { where(created_at: start_date..end_date) }

  # Declaration aggregation scopes
  scope :active_for_lead_provider, ->(lead_provider) { started.for_lead_provider(lead_provider).unique_id }
  scope :active_ects_for_lead_provider, ->(lead_provider) { active_for_lead_provider(lead_provider).ect }
  scope :active_mentors_for_lead_provider, ->(lead_provider) { active_for_lead_provider(lead_provider).mentor }
  scope :active_npqs_for_lead_provider, ->(lead_provider) { active_for_lead_provider(lead_provider).npq }
  scope :active_uplift_for_lead_provider, ->(lead_provider) { active_for_lead_provider(lead_provider).uplift }

  scope :payable_for_lead_provider, ->(lead_provider) { active_for_lead_provider(lead_provider).payable }
  scope :payable_ects_for_lead_provider, ->(lead_provider) { active_ects_for_lead_provider(lead_provider).payable }
  scope :payable_mentors_for_lead_provider, ->(lead_provider) { active_mentors_for_lead_provider(lead_provider).payable }
  scope :payable_npqs_for_lead_provider, ->(lead_provider) { active_npqs_for_lead_provider(lead_provider).payable }
  scope :payable_uplift_for_lead_provider, ->(lead_provider) { active_uplift_for_lead_provider(lead_provider).payable }

  def refresh_payability!
    new_state = fundable? ? "payable" : "submitted"
    return if current_state.state == new_state

    DeclarationState.create!(participant_declaration: self, state: new_state) and reload if %w[submitted payable].include?(current_state.state)
  end

  def submit
    DeclarationState.submit!(participant_declaration: self) and reload if payable?
  end

  def void!
    DeclarationState.void!(participant_declaration: self) and reload unless voided?
  end

  def pay!
    DeclarationState.pay!(participant_declaration: self) and reload if payable?
  end

  def changeable?
    %w[submitted payable].include?(current_state.state)
  end
end
